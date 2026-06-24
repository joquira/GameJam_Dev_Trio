extends CharacterBody2D

@export var left_limit := 0.0
@export var right_limit := 0.0
@export var speed := 80.0

const FRAME_SIZE := Vector2i(32, 32)
const ENEMY_ROW := 1
const WALK_COLUMNS := [0, 1, 2, 3]

var direction := 1.0
var gravity := 1250.0
var animation_time := 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if left_limit == 0.0 and right_limit == 0.0:
		left_limit = global_position.x - 120.0
		right_limit = global_position.x + 120.0

	if sprite.texture is AtlasTexture:
		sprite.texture = sprite.texture.duplicate()

	sprite.position = Vector2(0.0, -14.0)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

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

	_update_visual(delta)

func _update_visual(delta: float) -> void:
	animation_time += delta
	var frame_index := int(animation_time * 8.0) % WALK_COLUMNS.size()
	var texture := sprite.texture as AtlasTexture
	if texture:
		texture.region = Rect2(WALK_COLUMNS[frame_index] * FRAME_SIZE.x, ENEMY_ROW * FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y)

	sprite.flip_h = direction < 0.0

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("respawn"):
		body.respawn()
