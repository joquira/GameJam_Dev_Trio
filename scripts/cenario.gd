extends Node2D

const TILE_SIZE := 32
const SOURCE_TILE_SIZE := 16
const SCENERY_SHEET := preload("res://assets/tiles/sheet.png")

@onready var tile_map: TileMap = $LevelTiles
@onready var platforms: Node2D = $Platforms

func _ready() -> void:
	criar_tiles()
	criar_fase()

func criar_tiles() -> void:
	var source := TileSetAtlasSource.new()
	source.texture = SCENERY_SHEET
	source.texture_region_size = Vector2i(SOURCE_TILE_SIZE, SOURCE_TILE_SIZE)

	for y in range(8):
		for x in range(17):
			source.create_tile(Vector2i(x, y))

	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(SOURCE_TILE_SIZE, SOURCE_TILE_SIZE)
	tile_set.add_source(source, 0)

	tile_map.tile_set = tile_set
	tile_map.scale = Vector2(2, 2)
	tile_map.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func criar_fase() -> void:
	criar_plataforma(0, 18, 26)
	criar_plataforma(7, 14, 5)
	criar_plataforma(15, 11, 4)

	criar_plataforma(28, 18, 24)
	criar_plataforma(31, 15, 4)
	criar_plataforma(38, 12, 5)
	criar_plataforma(47, 10, 4)

	criar_plataforma(54, 18, 34)
	criar_plataforma(58, 13, 4)
	criar_plataforma(65, 10, 4)
	criar_plataforma(73, 8, 4)
	criar_plataforma(81, 12, 4)

	criar_plataforma(90, 18, 12)
	criar_plataforma(94, 14, 5)

func criar_plataforma(inicio_x: int, y: int, tamanho: int) -> void:
	for x in range(inicio_x, inicio_x + tamanho):
		var tile := Vector2i(7 + ((x - inicio_x) % 7), 0)
		tile_map.set_cell(0, Vector2i(x, y), 0, tile)

	var corpo := StaticBody2D.new()
	corpo.position = Vector2(inicio_x * TILE_SIZE + tamanho * TILE_SIZE / 2.0, y * TILE_SIZE + TILE_SIZE / 2.0)

	var colisao := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(tamanho * TILE_SIZE, TILE_SIZE)
	colisao.shape = forma

	corpo.add_child(colisao)
	platforms.add_child(corpo)
