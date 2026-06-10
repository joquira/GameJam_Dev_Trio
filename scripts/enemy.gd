extends CharacterBody2D

@export var left_limit := 0.0
@export var right_limit := 0.0
@export var speed := 80.0

var direction := 1.0
var gravity := 1250.0

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = direction * speed
	move_and_slide()

	if global_position.x <= left_limit:
		direction = 1.0
	elif global_position.x >= right_limit:
		direction = -1.0

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("respawn"):
		body.respawn()
