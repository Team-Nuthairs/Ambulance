class_name ChunkGridGenerator
extends RefCounted

## This is the function that actually generates the chunk grid.
## Inputs a grid width, height, and a seed
static func generate(width: int, height: int, seed: int) -> Array:
	var rng := RandomNumberGenerator.new()
	# Rng requires a seed to generate something actually random
	rng.seed = seed

	# The grid itself - grid[y][x] gives you the Chunk at that row/column.
	var grid: Array = []

	# --- PASS 1 ---
	# Walk every cell and roll its type completely independently, as if no
	# other chunk exists yet. We deliberately ignore neighbors here - that's
	# what pass 2 is for. This keeps the two concerns (what would this chunk
	# be on its own vs what does it actually end up as) easy to reason about
	# separately.
	for y in range(height):
		var row: Array = []
		for x in range(width):
			var chunk := Chunk.new()
			chunk.grid_x = x
			chunk.grid_y = y
			chunk.biome = _pick_biome(x, y, width, height)
			chunk.type = _pick_type(chunk.biome, rng)
			_apply_edges_for_type(chunk, rng)
			row.append(chunk)
		grid.append(row)

	# --- PASS 2 happens here, see below ---
	_reconcile_edges(grid, width, height)

	return grid
	
static func _pick_type(biome: int, rng: RandomNumberGenerator) -> int:
	var weights: Dictionary = Chunk.BIOME_WEIGHTS[biome]
	var roll := rng.randf() # a float between 0.0 and 1.0
	var cumulative := 0.0

	# Walk through each possible type and add up the odds as we go.
	# The moment our running total passes the random roll, that's our type.
	# This is the standard way to do weighted random selection.
	for type in weights:
		cumulative += weights[type]
		if roll < cumulative:
			return type

	# Fallback in case rounding error leaves us just short of 1.0 -
	# shouldn't normally trigger, but better than returning nothing.
	return ChunkType.STRAIGHT
	
static func _pick_biome(x: int, y: int, width: int, height: int) -> int:
	# For now, treat the grid center as "downtown" and let things get
	# rougher toward the edges. This is a placeholder rule - we'll want
	# something more deliberate once we actually place the garage and
	# decide where rich/poor neighborhoods should cluster.
	var center := Vector2(width / 2.0, height / 2.0)
	var dist := Vector2(x, y).distance_to(center)
	var max_dist := center.length()

	var t := dist / max_dist # 0.0 at center, 1.0 at the far corners

	if t < 0.3:
		return Biome.DOWNTOWN
	elif t < 0.7:
		return Biome.SUBURB
	else:
		return Biome.SLUM
		
static func _apply_edges_for_type(chunk: Chunk, rng: RandomNumberGenerator) -> void:
	match chunk.type:
		ChunkType.CULDESAC:
			# Only one edge is open. Pick which one at random.
			var dirs := ["n", "s", "e", "w"]
			var pick: String = dirs[rng.randi_range(0, 3)]
			chunk.edges[pick] = true
			chunk.has_node = true

		ChunkType.STRAIGHT:
			# Two opposite edges. Coin flip between vertical and horizontal.
			if rng.randf() < 0.5:
				chunk.edges["n"] = true
				chunk.edges["s"] = true
			else:
				chunk.edges["e"] = true
				chunk.edges["w"] = true
			chunk.has_node = false # straight roads don't need a node

		ChunkType.TURN:
			# Two adjacent edges. Four possible corner combinations.
			var corners := [["n","e"], ["e","s"], ["s","w"], ["w","n"]]
			var pick: Array = corners[rng.randi_range(0, 3)]
			chunk.edges[pick[0]] = true
			chunk.edges[pick[1]] = true
			chunk.has_node = true

		ChunkType.THREEWAY:
			# Three edges open, one closed. Pick which one is missing.
			var dirs := ["n", "s", "e", "w"]
			var missing: String = dirs[rng.randi_range(0, 3)]
			for d in dirs:
				chunk.edges[d] = (d != missing)
			chunk.has_node = true

		ChunkType.FOURWAY, ChunkType.DOUBLE_THREEWAY:
			# All four edges open, regardless of which of these two types
			# we end up being - the difference is handled separately, see
			# the double_threeway split logic later.
			chunk.edges["n"] = true
			chunk.edges["s"] = true
			chunk.edges["e"] = true
			chunk.edges["w"] = true
			chunk.has_node = true

static func _reconcile_edges(grid: Array, width: int, height: int) -> void:
	# We only need to check west and north neighbors here. Walking the grid
	# left to right, top to bottom means those two neighbors were already
	# finalized by the time we get to the current chunk - so checking them
	# is enough to catch every shared edge exactly once. We don't need to
	# check east/south because when *those* chunks get visited, *they'll*
	# check back against us.
	for y in range(height):
		for x in range(width):
			var chunk: Chunk = grid[y][x]

			# Check the western neighbor (the chunk to our left)
			if x > 0:
				var west: Chunk = grid[y][x - 1]
				_reconcile_pair(chunk, "w", west, "e")

			# Check the northern neighbor (the chunk above us)
			if y > 0:
				var north: Chunk = grid[y - 1][x]
				_reconcile_pair(chunk, "n", north, "s")

static func _reconcile_pair(chunk: Chunk, chunk_dir: String, neighbor: Chunk, neighbor_dir: String) -> void:
	var chunk_wants: bool = chunk.edges[chunk_dir]
	var neighbor_wants: bool = neighbor.edges[neighbor_dir]

	# Both sides already agree - nothing to do. This covers both "both true"
	# (a road connects them, great) and "both false" (no road, also fine).
	if chunk_wants == neighbor_wants:
		return

	# Disagreement. One side wants a road here, the other doesn't.
	# Per our "promote over demote" rule, we try to upgrade whichever side
	# is missing the connection, rather than tearing down the side that
	# already has it.
	if chunk_wants and not neighbor_wants:
		_promote_or_demote(neighbor, neighbor_dir, chunk, chunk_dir)
	elif neighbor_wants and not chunk_wants:
		_promote_or_demote(chunk, chunk_dir, neighbor, neighbor_dir)


static func _promote_or_demote(loser: Chunk, loser_dir: String, winner: Chunk, winner_dir: String) -> void:
	# "loser" is the chunk that's missing an edge the other side wants.
	# First, see if loser can simply be upgraded to a type that supports
	# one more edge than it currently has.
	var current_count: int = Chunk.TYPE_EDGE_COUNT[loser.type]
	var next_type = _find_type_with_count(current_count + 1)

	if next_type != null:
		# Promotion succeeded. Upgrade the type, then turn on exactly the
		# one new edge we needed - everything else about the chunk stays
		# the same as it already was.
		loser.type = next_type
		loser.edges[loser_dir] = true
		loser.has_node = true
	else:
		# Can't promote any further (already a 4-way). As a last resort,
		# demote the *winner* instead - turn off the edge it wanted, since
		# the loser genuinely has no room to accept it.
		winner.edges[winner_dir] = false
		# Note: this could change winner's type too (e.g. a 4-way losing an
		# edge becomes a 3-way) - but we leave that for now since 4-way is
		# the max type and dropping to 3-way doesn't break anything to leave
		# for a later cleanup pass if we want one.


static func _find_type_with_count(count: int):
	for type in Chunk.TYPE_EDGE_COUNT:
		if Chunk.TYPE_EDGE_COUNT[type] == count:
			return type
	return null # no type needs this many edges (count > 4, shouldn't happen)
