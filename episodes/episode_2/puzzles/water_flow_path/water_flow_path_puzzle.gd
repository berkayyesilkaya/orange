class_name WaterFlowPathPuzzle
extends PuzzleBase

@export var expected_open: Array[StringName] = [
	&"ep2.water_flow.channel_1",
	&"ep2.water_flow.channel_3",
]

var _channel_open: Dictionary = {
	&"ep2.water_flow.channel_1": false,
	&"ep2.water_flow.channel_2": false,
	&"ep2.water_flow.channel_3": false,
}

const _CHANNEL_NODES: Dictionary = {
	&"ep2.water_flow.channel_1": "Channel1",
	&"ep2.water_flow.channel_2": "Channel2",
	&"ep2.water_flow.channel_3": "Channel3",
}

var _im: InteractionManager = null


func _ready() -> void:
	super()
	if _state == State.INACTIVE:
		start_puzzle()
	if _state == State.ACTIVE:
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

	if id == &"ep2.water_flow.confirm":
		if _is_correct_combo():
			mark_solved()
		else:
			EventBus.dialogue_requested.emit(&"ep2.water_flow_wrong")
		return

	if not _channel_open.has(id):
		return
	_channel_open[id] = not _channel_open[id]
	_update_channel_label(id)
	_update_flow_indicator()


func _update_channel_label(channel_id: StringName) -> void:
	var node_name: String = _CHANNEL_NODES.get(channel_id, "")
	if node_name.is_empty():
		return
	var channel := get_node_or_null(node_name) as Interactable
	if channel:
		channel.action_label = "Close" if _channel_open[channel_id] else "Open"


func _update_flow_indicator() -> void:
	var indicator := get_node_or_null("FlowIndicator") as Sprite2D
	if not indicator:
		return
	var any_open := false
	for id in _channel_open:
		if _channel_open[id]:
			any_open = true
			break
	indicator.modulate = Color(0.2, 0.6, 1.0, 1.0) if any_open else Color.WHITE


func _is_correct_combo() -> bool:
	var open_ids: Array[StringName] = []
	for id in _channel_open:
		if _channel_open[id]:
			open_ids.append(id)
	if open_ids.size() != expected_open.size():
		return false
	for id in expected_open:
		if not open_ids.has(id):
			return false
	return true


func _on_already_solved() -> void:
	for node_name in _CHANNEL_NODES.values():
		var node := get_node_or_null(node_name)
		if node:
			node.hide()
	var confirm := get_node_or_null("ConfirmFlow")
	if confirm:
		confirm.hide()
	if is_instance_valid(_im) and _im.action_dispatched.is_connected(_on_action_dispatched):
		_im.action_dispatched.disconnect(_on_action_dispatched)
