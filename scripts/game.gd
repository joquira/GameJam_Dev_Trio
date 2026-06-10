extends Node2D

const TILE_SIZE := 32
const SOURCE_TILE_SIZE := 16

const SCENERY_SHEET := preload("res://assets/tiles/sheet.png")

@onready var tile_map: TileMap = $LevelTiles
@onready var platforms: Node2D = $Platforms
@onready var player: CharacterBody2D = $Player
@onready var hud_label: Label = $CanvasLayer/HUD
@onready var message_label: Label = $CanvasLayer/Message

var baus := 0
var tempo_pulo_alto := 8.0

func _ready() -> void:
	criar_tiles()
	criar_fase()
	conectar_objetos()
	atualizar_hud()
	mostrar_mensagem("Pegue os 2 baus e chegue na porta final.")

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

func conectar_objetos() -> void:
	for bau in get_tree().get_nodes_in_group("baus"):
		bau.coletado.connect(pegou_bau)

	for power_up in get_tree().get_nodes_in_group("powerups"):
		power_up.coletado.connect(pegou_power_up_pulo)

	for porta in get_tree().get_nodes_in_group("portas"):
		porta.entrou.connect(chegou_na_porta)

func pegou_bau(body: Node2D, bau: Area2D) -> void:
	if body != player:
		return

	baus += 1
	bau.queue_free()
	atualizar_hud()
	mostrar_mensagem("Bau coletado!")

func pegou_power_up_pulo(body: Node2D, power_up: Area2D) -> void:
	if body != player:
		return

	power_up.queue_free()
	player.ativar_pulo_alto()
	atualizar_hud()
	mostrar_mensagem("Power-up: pulo alto!")
	await get_tree().create_timer(tempo_pulo_alto).timeout
	player.desativar_pulo_alto()
	atualizar_hud()
	mostrar_mensagem("O pulo alto acabou.")

func chegou_na_porta(body: Node2D) -> void:
	if body != player:
		return

	if baus < 2:
		mostrar_mensagem("Pegue os 2 baus antes de terminar.")
		return

	player.controls_enabled = false
	mostrar_mensagem("Voce venceu!")

func atualizar_hud() -> void:
	hud_label.text = "%d/2 | A/D move | Espaco pula | Shift corre" % baus
	if player.pulo_alto:
		hud_label.text += " | Pulo alto"

func mostrar_mensagem(texto: String) -> void:
	message_label.text = texto
	message_label.modulate.a = 1
