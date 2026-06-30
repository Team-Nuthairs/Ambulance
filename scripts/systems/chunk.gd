class_name Chunk
extends RefCounted

## One square cell of the world grid. A chunk either has a road intersection
## in it, or is just empty space the road passes through (or doesn't touch at all).

## Which of the 4 sides of this chunk have a road connecting to the chunk next to it.
## true means a road crosses that border. Two neighboring chunks must always
## agree on the edge between them - if chunk A says "south: true" then the
## chunk below it must also say "north: true", or the road wouldn't line up.
var edges := {"n": false, "s": false, "e": false, "w": false}

## What kind of intersection this chunk turned out to be (4-way, dead end, etc).
## Decided by rolling against the biome's odds, then possibly upgraded later
## if a neighboring chunk needed an extra connection we didn't originally have.
## The values for ChunkType and Biome can be found as global enums in the num folder
var type: int = ChunkType.UNSET

## Which neighborhood "flavor" this chunk belongs to. Controls the odds of
## getting different intersection types - a suburb rolls more dead ends,
## downtown rolls more 4-ways, etc.
var biome: int = Biome.DOWNTOWN

## The exact pixel/world position of the intersection inside this chunk.
## Offset slightly from dead-center so the streets don't look like a
## perfectly uniform grid.
var node_pos: Vector2 = Vector2.ZERO

## This chunk's column and row in the overall grid. Used to find which
## chunks are this one's neighbors (the chunk to the east is grid_x + 1, etc).
var grid_x: int
var grid_y: int

## Whether this chunk actually has a usable intersection point in it.
## A "straight" road segment has no node - cars just drive through without
## stopping or turning, so there's nothing to mark.
var has_node: bool = false

## True only for the rare case where one chunk contains two separate
## intersections instead of one (see double_threeway below). This basically
## never happens and most chunks can ignore it.
var is_split: bool = false

## If is_split is true, this says whether the chunk divides into a left/right
## half or a top/bottom half. Empty string if the chunk isn't split.
var split_axis: SplitAxis = SplitAxis.HORIZONTAL

## These store the names of the types for thier respective vars
## The enums and weights are locally scoped and the class name must be added
## as a prefix when used externally e.g.: Chunk.SplitAxis
enum SplitAxis {
	HORIZONTAL,
	VERTICAL,
}

## How many of the 4 edges each intersection type actually uses.
## This is what the negotiation logic checks against when a chunk needs to
## accept one more connection than it currently has - it looks up "the next
## type that needs one more edge than me" and upgrades to that.
const TYPE_EDGE_COUNT := {
	ChunkType.CULDESAC: 1,
	ChunkType.STRAIGHT: 2,
	ChunkType.TURN: 2,
	ChunkType.THREEWAY: 3,
	ChunkType.FOURWAY: 4,
	ChunkType.DOUBLE_THREEWAY: 4,
}

## The odds of rolling each intersection type, broken down by neighborhood.
## Read it as "if this chunk is in this biome, what % chance does each type have."
## These numbers are first-guess placeholders - we'll tune them once we can
## actually see the results.
const BIOME_WEIGHTS := {
	Biome.DOWNTOWN: {ChunkType.FOURWAY: 0.45, ChunkType.THREEWAY: 0.3, ChunkType.STRAIGHT: 0.15, ChunkType.TURN: 0.05, ChunkType.CULDESAC: 0.05},
	Biome.SUBURB:   {ChunkType.FOURWAY: 0.1,  ChunkType.THREEWAY: 0.25,ChunkType.STRAIGHT: 0.3,  ChunkType.TURN: 0.2,  ChunkType.CULDESAC: 0.15},
	Biome.SLUM:     {ChunkType.FOURWAY: 0.2,  ChunkType.THREEWAY: 0.2, ChunkType.STRAIGHT: 0.25, ChunkType.TURN: 0.2,  ChunkType.CULDESAC: 0.15},
}
