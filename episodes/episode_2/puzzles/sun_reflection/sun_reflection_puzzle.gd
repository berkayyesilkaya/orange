class_name SunReflectionPuzzle
extends PuzzleBase

@export var correct_rotation_stone1: int = 2
@export var correct_rotation_stone2: int = 1
@export var correct_rotation_stone3: int = 3

var _rotations: Dictionary = {
	&"ep2.sun_reflection.stone_1": 0,
	&"ep2.sun_reflection.stone_2": 0,
	&"ep2.sun_reflection.stone_3": 0,
}

const _STONE_NODES: Dictionary = {
	&"ep2.sun_reflection.stone_1": "Stone1",
	&"ep2.sun_reflection.stone_2": "Stone2",
	&"ep2.sun_reflection.stone_3": "Stone3",
}

var _im: InteractionManager = null


func _ready() -> void:
	super()
	if _state == State.INACTIVE:
		call_deferred("_deferred_start")
	elif _state == State.ACTIVE:
		_connect_manager()


func _deferred_start() -> void:
	if _state != State.INACTIVE:
		return
	start_puzzle()
	_connect_manager()


func _connect_manager() -> void:
	var im := get_tree().get_current_scene().get_node_or_null("InteractionManager") as InteractionManager
	if im:
		_im = im
		im.action_dispatched.connect(_on_action_dispatched)


func _on_action_dispatched(interactable: Interactable) -> void:
	if _state != State.ACTIVE:
		return
	var id := interactable.interactable_id
	if not str(id).begins_with("ep2.sun_reflection."):
		return
	_rotations[id] = (_rotations[id] + 1) % 4
	_update_stone_visual(id)
	if (_rotations[&"ep2.sun_reflection.stone_1"] == correct_rotation_stone1
			and _rotations[&"ep2.sun_reflection.stone_2"] == correct_rotation_stone2
			and _rotations[&"ep2.sun_reflection.stone_3"] == correct_rotation_stone3):
		mark_solved()


func _update_stone_visual(stone_id: StringName) -> void:
	var node_name: String = _STONE_NODES.get(stone_id, "")
	if node_name.is_empty():
		return
	var stone := get_node_or_null(node_name)
	if not stone:
		return
	var sprite := stone.get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.rotation_degrees = _rotations[stone_id] * 90.0


func _on_already_solved() -> void:
	_rotations[&"ep2.sun_reflection.stone_1"] = correct_rotation_stone1
	_rotations[&"ep2.sun_reflection.stone_2"] = correct_rotation_stone2
	_rotations[&"ep2.sun_reflection.stone_3"] = correct_rotation_stone3
	for stone_id: StringName in _STONE_NODES:
		_update_stone_visual(stone_id)
		var node := get_node_or_null(_STONE_NODES[stone_id])
		if node:
			node.hide()
	if is_instance_valid(_im) and _im.action_dispatched.is_connected(_on_action_dispatched):
		_im.action_dispatched.disconnect(_on_action_dispatched)
