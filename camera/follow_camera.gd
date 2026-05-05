class_name FollowCamera
extends Camera2D

@export var target_path: NodePath
# When size != Vector2.ZERO the camera position is clamped to this rect.
@export var bounds: Rect2 = Rect2()

var _target: Node2D


func _ready() -> void:
	if not target_path.is_empty():
		_target = get_node_or_null(target_path) as Node2D


func _process(_delta: float) -> void:
	if not is_instance_valid(_target):
		return

	var pos := _target.global_position

	if bounds.size != Vector2.ZERO:
		pos = pos.clamp(bounds.position, bounds.end)

	global_position = pos
