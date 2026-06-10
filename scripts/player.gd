extends CharacterBody2D

const WALK_SPEED := 210.0
const RUN_SPEED := 320.0
const JUMP_FORCE := -500.0
const HIGH_JUMP_FORCE := -760.0
const FRAME_SIZE := Vector2i(32, 32)
const CHARACTER_ROW := 0
const CHARACTER_SHEET := preload("res://assets/sprites/characters.png")

var gravity := 1250.0
var jump_force := JUMP_FORCE
var spawn_position := Vector2.ZERO
var controls_enabled := true
var pulo_alto := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	spawn_position = global_position
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(2.0, 2.0)
	_setup_animations()

func _physics_process(delta: float) -> void:
	if not controls_enabled:
		return

	var direction := Input.get_axis("move_left", "move_right")
	var target_speed := RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED

	if direction != 0.0:
		velocity.x = direction * target_speed
		sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, target_speed * 8.0 * delta)

	if not is_on_floor():
		velocity.y += gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_force

	move_and_slide()
	_update_animation(direction, target_speed)

	if global_position.y > 900.0:
		respawn()

func respawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO

func ativar_pulo_alto() -> void:
	pulo_alto = true
	jump_force = HIGH_JUMP_FORCE

func desativar_pulo_alto() -> void:
	pulo_alto = false
	jump_force = JUMP_FORCE

func _update_animation(direction: float, target_speed: float) -> void:
	if not is_on_floor():
		sprite.play("jump")
	elif abs(direction) > 0.01 and target_speed == RUN_SPEED:
		sprite.play("run")
	elif abs(direction) > 0.01:
		sprite.play("walk")
	else:
		sprite.play("idle")

func _setup_animations() -> void:
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.add_animation("walk")
	frames.add_animation("run")
	frames.add_animation("jump")

	frames.set_animation_speed("idle", 4.0)
	frames.set_animation_speed("walk", 8.0)
	frames.set_animation_speed("run", 12.0)
	frames.set_animation_speed("jump", 1.0)

	frames.add_frame("idle", _frame(0))
	frames.add_frame("idle", _frame(1))
	frames.add_frame("idle", _frame(2))

	for column in [5, 6, 7, 8, 9, 10]:
		frames.add_frame("walk", _frame(column))

	for column in [11, 12, 13, 14, 15, 16]:
		frames.add_frame("run", _frame(column))

	frames.add_frame("jump", _frame(17))
	sprite.sprite_frames = frames
	sprite.play("idle")

func _frame(column: int) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = CHARACTER_SHEET
	texture.region = Rect2(column * FRAME_SIZE.x, CHARACTER_ROW * FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y)
	return texture
