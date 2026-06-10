extends Area2D

signal coletado(body, bau)

func _on_body_entered(body: Node2D) -> void:
	coletado.emit(body, self)
