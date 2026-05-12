class_name RockWaterPuzzle
extends PuzzleBase

@export var expected_order: Array[StringName] = [
	&"ep2.rock_water.mark_a",
	&"ep2.rock_water.mark_b",
	&"ep2.rock_water.mark_c",
	&"ep2.rock_water.mark_d",
]

var _tapped_sequence: Array[StringName] = []

const _MARK_NODES: Dictionary = {
	&"ep2.rock_water.mark_a": "MarkA",
	&"ep2.rock_water.mark_b": "MarkB",
	&"ep2.rock_water.mark_c": "MarkC",
	&"ep2.rock_water.mark_d": "MarkD",
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
	if not str(id).begins_with("ep2.rock_water.mark_"):
		return

	_tapped_sequence.append(id)

	if not _is_valid_prefix():
		_tapped_sequence.clear()
		EventBus.dialogue_requested.emit(&"ep2.rock_water_wrong")
		return

	_highlight_mark(id)

	if _tapped_sequence.size() == expected_order.size():
		mark_solved()


func _is_valid_prefix() -> bool:
	var n := _tapped_sequence.size()
	if n > expected_order.size():
		return false
	for i in n:
		if _tapped_sequence[i] != expected_order[i]:
			return false
	return true


func _highlight_mark(mark_id: StringName) -> void:
	var node_name: String = _MARK_NODES.get(mark_id, "")
	if node_name.is_empty():
		return
	var mark := get_node_or_null(node_name)
	if not mark:
		return
	var sprite := mark.get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.modulate = Color(1.0, 0.85, 0.2, 1.0)


func _on_already_solved() -> void:
	for mark_id: StringName in _MARK_NODES:
		_highlight_mark(mark_id)
		var node := get_node_or_null(_MARK_NODES[mark_id])
		if node:
			node.hide()
	if is_instance_valid(_im) and _im.action_dispatched.is_connected(_on_action_dispatched):
		_im.action_dispatched.disconnect(_on_action_dispatched)
