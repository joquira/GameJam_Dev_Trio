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
	var tile_map: Node = main.get_node_or_null("LevelTiles")
	var hud: Label = main.get_node_or_null("CanvasLayer/HUD")
	if player == null or tile_map == null or hud == null:
		push_error("Required gameplay nodes are missing.")
		quit(1)
		return

	print("SMOKE_OK player=%s tile_map=%s hud=%s" % [player.name, tile_map.name, hud.text])
	quit()
