extends Area2D

signal entrou(body)

func _on_body_entered(body: Node2D) -> void:
	entrou.emit(body)
