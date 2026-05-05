class_name OrangeCharacter
extends CharacterBody2D

signal arrived_at_target

@export var walk_speed: float = 90.0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var _target: Vector2 = Vector2.ZERO
var _has_target: bool = false

var is_moving: bool:
	get:
		return _has_target


func _ready() -> void:
	_setup_idle_animation()


func move_to(target: Vector2) -> void:
	_target = target
	_has_target = true


func _physics_process(_delta: float) -> void:
	if not _has_target:
		velocity = Vector2.ZERO
		return

	var to_target := _target - global_position
	if to_target.length() <= 2.0:
		global_position = _target
		velocity = Vector2.ZERO
		_has_target = false
		arrived_at_target.emit()
		return

	velocity = to_target.normalized() * walk_speed
	move_and_slide()


func _setup_idle_animation() -> void:
	var library := AnimationLibrary.new()
	var anim := Animation.new()
	anim.loop_mode = Animation.LOOP_LINEAR
	anim.length = 1.2

	# Gentle vertical bob: 0 → -3px (up) → 0
	var track_idx := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, "Sprite2D:position:y")
	anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_CUBIC)
	anim.track_insert_key(track_idx, 0.0, 0.0)
	anim.track_insert_key(track_idx, 0.6, -3.0)
	anim.track_insert_key(track_idx, 1.2, 0.0)

	library.add_animation(&"idle", anim)
	_animation_player.add_animation_library(&"", library)
	_animation_player.play(&"idle")
