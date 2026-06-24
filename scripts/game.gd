extends Node2D

@onready var player = $Player
@onready var hud_label: Label = $CanvasLayer/HUD
@onready var message_label: Label = $CanvasLayer/Message
@onready var start_panel: Panel = $CanvasLayer/StartPanel
@onready var end_panel: Panel = $CanvasLayer/EndPanel
@onready var pause_panel: Panel = $CanvasLayer/PausePanel
@onready var fase_1_button: Button = $CanvasLayer/StartPanel/Fase1Button
@onready var continue_button: Button = $CanvasLayer/PausePanel/ContinueButton
@onready var exit_button: Button = $CanvasLayer/PausePanel/ExitButton

var baus := 0
var tempo_pulo_alto := 8.0
var jogo_iniciado := false
var jogo_finalizado := false
var message_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	conectar_objetos()
	player.controls_enabled = false
	start_panel.visible = true
	end_panel.visible = false
	pause_panel.visible = false
	pause_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	atualizar_hud()
	mostrar_mensagem("Selecione uma fase no hub.")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and jogo_iniciado and not jogo_finalizado:
		if get_tree().paused:
			continuar_jogo()
		else:
			pausar_jogo()
		return

	if not jogo_iniciado and event.is_action_pressed("jump"):
		iniciar_jogo()

func conectar_objetos() -> void:
	fase_1_button.pressed.connect(iniciar_jogo)
	continue_button.pressed.connect(continuar_jogo)
	exit_button.pressed.connect(sair_do_jogo)
	player.respawned.connect(player_respawnou)

	for bau in get_tree().get_nodes_in_group("baus"):
		bau.coletado.connect(pegou_bau)

	for power_up in get_tree().get_nodes_in_group("powerups"):
		power_up.coletado.connect(pegou_power_up_pulo)

	for porta in get_tree().get_nodes_in_group("portas"):
		porta.entrou.connect(chegou_na_porta)

func iniciar_jogo() -> void:
	if jogo_iniciado:
		return

	jogo_iniciado = true
	player.controls_enabled = true
	start_panel.visible = false
	mostrar_mensagem("Pegue os 2 baus e chegue na porta final.")

func pausar_jogo() -> void:
	pause_panel.visible = true
	player.controls_enabled = false
	get_tree().paused = true

func continuar_jogo() -> void:
	get_tree().paused = false
	pause_panel.visible = false
	if jogo_iniciado and not jogo_finalizado:
		player.controls_enabled = true
	mostrar_mensagem("Jogo retomado.")

func sair_do_jogo() -> void:
	get_tree().paused = false
	get_tree().quit()

func pegou_bau(body: Node2D, bau: Area2D) -> void:
	if body != player or jogo_finalizado:
		return

	baus += 1
	bau.queue_free()
	atualizar_hud()
	if baus >= 2:
		mostrar_mensagem("Todos os baus foram coletados. Va ate a porta!")
	else:
		mostrar_mensagem("Bau coletado!")

func pegou_power_up_pulo(body: Node2D, power_up: Area2D) -> void:
	if body != player or jogo_finalizado:
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
	if body != player or jogo_finalizado:
		return

	if baus < 2:
		mostrar_mensagem("Pegue os 2 baus antes de terminar.")
		return

	player.controls_enabled = false
	jogo_finalizado = true
	end_panel.visible = true
	mostrar_mensagem("Voce venceu! A luz atras da porta revelou a saida.")

func player_respawnou() -> void:
	if jogo_finalizado:
		return

	player.desativar_pulo_alto()
	atualizar_hud()
	mostrar_mensagem("Cuidado! Voce voltou ao inicio.")

func atualizar_hud() -> void:
	hud_label.text = "%d/2 baus | A/D move | Espaco pula | Shift corre | Esc pausa" % baus
	if player.pulo_alto:
		hud_label.text += " | Pulo alto"

func mostrar_mensagem(texto: String) -> void:
	if message_tween:
		message_tween.kill()

	message_label.text = texto
	message_label.modulate.a = 1
	message_tween = create_tween()
	message_tween.tween_interval(2.2)
	message_tween.tween_property(message_label, "modulate:a", 0.0, 0.6)
