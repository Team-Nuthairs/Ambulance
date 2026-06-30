extends Node2D

## Reads whatever ChunkGridGenerator produced and draws it on screen.
## This script knows nothing about how chunks were decided - it just
## reads chunk.edges, chunk.has_node, chunk.type and draws shapes.
## If something looks wrong, check the generator first; this is "dumb" on purpose.

@export var grid_width: int = 10
@export var grid_height: int = 8
@export var seed: int = 1
@export var cell_size: int = 64

var grid: Array = []

# Used to turn an edge direction into a vector pointing that way on screen.
const DIR_VECTORS := {
	"n": Vector2(0, -1),
	"s": Vector2(0, 1),
	"e": Vector2(1, 0),
	"w": Vector2(-1, 0),
}

func _ready() -> void:
	grid = ChunkGridGenerator.generate(grid_width, grid_height, seed)
	queue_redraw() # tells Godot to call _draw() now that we have data

func _draw() -> void:
	for y in range(grid_height):
		for x in range(grid_width):
			var chunk: Chunk = grid[y][x]
			var top_left := Vector2(x, y) * cell_size
			var center := top_left + Vector2(cell_size, cell_size) / 2.0

			# Outline every cell faintly so the grid itself is visible
			draw_rect(Rect2(top_left, Vector2(cell_size, cell_size)), Color(0.3, 0.3, 0.3), false)

			# Draw a line toward every active edge direction
			for dir in chunk.edges:
				if chunk.edges[dir]:
					var dir_vec: Vector2 = DIR_VECTORS[dir]
					draw_line(center, center + dir_vec * cell_size / 2.0, Color.LIME_GREEN, 3.0)

			# Mark the intersection node itself, if this chunk has one
			if chunk.has_node:
				draw_circle(center, 6.0, Color.WHITE)

			# Color-code the biome as a faint background tint, just so it's
			# visually obvious the biome system is feeding into generation
			var biome_color := _biome_debug_color(chunk.biome)
			draw_rect(Rect2(top_left, Vector2(cell_size, cell_size)), biome_color, true)

func _biome_debug_color(biome: int) -> Color:
	match biome:
		Biome.DOWNTOWN:
			return Color(0.2, 0.2, 0.5, 0.3)
		Biome.SUBURB:
			return Color(0.2, 0.5, 0.2, 0.3)
		Biome.SLUM:
			return Color(0.5, 0.3, 0.1, 0.3)
		_:
			return Color(0, 0, 0, 0) # transparent fallback
