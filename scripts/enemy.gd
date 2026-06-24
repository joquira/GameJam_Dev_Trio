extends CharacterBody2D

@export var left_limit := 0.0
@export var right_limit := 0.0
@export var speed := 80.0

var direction := 1.0
var gravity := 1250.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if left_limit == 0.0 and right_limit == 0.0:
		left_limit = global_position.x - 120.0
		right_limit = global_position.x + 120.0

	sprite.position = Vector2(0.0, -14.0)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.play("walk")

func _physics_process(delta: float) -> void:
	if is_on_floor() and velocity.y > 0.0:
		velocity.y = 0.0
	else:
		velocity.y += gravity * delta

	if global_position.x <= left_limit:
		direction = 1.0
	elif global_position.x >= right_limit:
		direction = -1.0

	velocity.x = direction * speed
	move_and_slide()

	if is_on_wall():
		direction *= -1.0

	sprite.flip_h = direction < 0.0

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("respawn"):
		body.respawn()
