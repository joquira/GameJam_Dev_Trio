extends SceneTree

func _initialize() -> void:
	var packed := load("res://scenes/main.tscn")
	if packed == null:
		push_error("Main scene did not load.")
		quit(1)
		return

	var main: Node = packed.instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame

	var player: Node = main.get_node_or_null("Player")
	var cenario: Node = main.get_node_or_null("Cenario")
	var tile_map: Node = main.get_node_or_null("Cenario/LevelTiles")
	var hud: Label = main.get_node_or_null("CanvasLayer/HUD")
	var start_panel: Panel = main.get_node_or_null("CanvasLayer/StartPanel")
	var end_panel: Panel = main.get_node_or_null("CanvasLayer/EndPanel")
	var pause_panel: Panel = main.get_node_or_null("CanvasLayer/PausePanel")
	var fase_1_button: Button = main.get_node_or_null("CanvasLayer/StartPanel/Fase1Button")
	var continue_button: Button = main.get_node_or_null("CanvasLayer/PausePanel/ContinueButton")
	var exit_button: Button = main.get_node_or_null("CanvasLayer/PausePanel/ExitButton")
	var enemy: CharacterBody2D = main.get_node_or_null("Actors/Inimigo1")
	if player == null or cenario == null or tile_map == null or hud == null or start_panel == null or end_panel == null or pause_panel == null or fase_1_button == null or continue_button == null or exit_button == null or enemy == null:
		push_error("Required gameplay nodes are missing.")
		quit(1)
		return

	if not start_panel.visible or end_panel.visible or pause_panel.visible:
		push_error("Menu panels are not in the expected initial state.")
		quit(1)
		return

	main.iniciar_jogo()
	main.pausar_jogo()
	if not paused or not pause_panel.visible:
		push_error("Pause menu did not open correctly.")
		quit(1)
		return

	main.continuar_jogo()
	if paused or pause_panel.visible:
		push_error("Pause menu did not close correctly.")
		quit(1)
		return

	var enemy_start_x := enemy.global_position.x
	for i in range(20):
		await physics_frame

	if not enemy.is_on_floor() or abs(enemy.global_position.x - enemy_start_x) < 1.0:
		push_error("Enemy should be grounded and patrolling.")
		quit(1)
		return

	print("SMOKE_OK player=%s cenario=%s tile_map=%s hud=%s start=%s pause=%s end=%s enemy_x=%.1f" % [player.name, cenario.name, tile_map.name, hud.text, start_panel.visible, pause_panel.visible, end_panel.visible, enemy.global_position.x])
	quit()
