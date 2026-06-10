extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hud_label: Label = $CanvasLayer/HUD
@onready var message_label: Label = $CanvasLayer/Message

var baus := 0
var tempo_pulo_alto := 8.0

func _ready() -> void:
	conectar_objetos()
	atualizar_hud()
	mostrar_mensagem("Pegue os 2 baus e chegue na porta final.")

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
