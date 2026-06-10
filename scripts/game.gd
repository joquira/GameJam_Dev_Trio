extends Node2D

const TILE_SIZE := 32
const SOURCE_TILE_SIZE := 16

const SCENERY_SHEET := preload("res://assets/tiles/sheet.png")
const CHARACTERS_SHEET := preload("res://assets/sprites/characters.png")

@onready var tile_map: TileMap = $LevelTiles
@onready var platforms: Node2D = $Platforms
@onready var actors: Node2D = $Actors
@onready var player: CharacterBody2D = $Player
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var hud_label: Label = $CanvasLayer/HUD
@onready var message_label: Label = $CanvasLayer/Message

var baus := 0
var tempo_pulo_alto := 8.0
var icone_bau: TextureRect

func _ready() -> void:
	criar_tiles()
	criar_hud()
	criar_fase()
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

	criar_bau(Vector2(1510, 304))
	criar_bau(Vector2(2370, 200))
	criar_power_up_pulo(Vector2(1430, 304))

	criar_inimigo(Vector2(1190, 520), 1060, 1410)
	criar_inimigo(Vector2(2070, 520), 1850, 2250)

	criar_porta_final(Vector2(3180, 576))

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

func criar_bau(posicao: Vector2) -> void:
	var bau := Area2D.new()
	bau.position = posicao

	var colisao := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(38, 30)
	colisao.shape = forma
	bau.add_child(colisao)

	var sprite := Sprite2D.new()
	sprite.texture = pegar_sprite(SCENERY_SHEET, Rect2(224, 64, 16, 16))
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(2.4, 2.4)
	bau.add_child(sprite)

	bau.body_entered.connect(pegou_bau.bind(bau))
	actors.add_child(bau)

func criar_hud() -> void:
	icone_bau = TextureRect.new()
	icone_bau.texture = pegar_sprite(SCENERY_SHEET, Rect2(224, 64, 16, 16))
	icone_bau.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icone_bau.position = Vector2(18, 12)
	icone_bau.size = Vector2(34, 34)
	icone_bau.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	canvas_layer.add_child(icone_bau)
	hud_label.offset_left = 58

func criar_power_up_pulo(posicao: Vector2) -> void:
	var power_up := Area2D.new()
	power_up.position = posicao

	var colisao := CollisionShape2D.new()
	var forma := CircleShape2D.new()
	forma.radius = 18
	colisao.shape = forma
	power_up.add_child(colisao)

	var sprite := Sprite2D.new()
	sprite.texture = pegar_sprite(SCENERY_SHEET, Rect2(128, 80, 16, 16))
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(2.5, 2.5)
	power_up.add_child(sprite)

	power_up.body_entered.connect(pegou_power_up_pulo.bind(power_up))
	actors.add_child(power_up)

func criar_inimigo(posicao: Vector2, limite_esquerda: float, limite_direita: float) -> void:
	var inimigo := preload("res://scripts/enemy.gd").new()
	inimigo.position = posicao
	inimigo.left_limit = limite_esquerda
	inimigo.right_limit = limite_direita

	var colisao := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(34, 28)
	colisao.shape = forma
	inimigo.add_child(colisao)

	var area_dano := Area2D.new()
	var colisao_dano := CollisionShape2D.new()
	var forma_dano := RectangleShape2D.new()
	forma_dano.size = Vector2(42, 36)
	colisao_dano.shape = forma_dano
	area_dano.add_child(colisao_dano)
	area_dano.body_entered.connect(inimigo._on_body_entered)
	inimigo.add_child(area_dano)

	var sprite := Sprite2D.new()
	sprite.texture = pegar_sprite(CHARACTERS_SHEET, Rect2(0, 32, 32, 32))
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(1.7, 1.7)
	sprite.position = Vector2(0, -30)
	inimigo.add_child(sprite)

	actors.add_child(inimigo)

func criar_porta_final(posicao: Vector2) -> void:
	var porta := Area2D.new()
	porta.position = posicao

	var colisao := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(56, 90)
	colisao.shape = forma
	porta.add_child(colisao)

	var sprite := Sprite2D.new()
	sprite.texture = pegar_sprite(SCENERY_SHEET, Rect2(64, 64, 16, 32))
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(3.5, 3.5)
	sprite.position = Vector2(0, -54)
	porta.add_child(sprite)

	porta.body_entered.connect(chegou_na_porta)
	actors.add_child(porta)

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

func pegar_sprite(atlas: Texture2D, regiao: Rect2) -> AtlasTexture:
	var sprite := AtlasTexture.new()
	sprite.atlas = atlas
	sprite.region = regiao
	return sprite
