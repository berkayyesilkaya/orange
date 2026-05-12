class_name MistSymbolPuzzle
extends PuzzleBase

@export var correct_panel: StringName = &"ep2.mist_symbol.panel_c"

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
	if not str(id).begins_with("ep2.mist_symbol.panel_"):
		return
	if id == correct_panel:
		mark_solved()
	else:
		EventBus.dialogue_requested.emit(&"ep2.mist_symbol_wrong")


func _on_already_solved() -> void:
	for panel_name: String in ["PanelA", "PanelB", "PanelC", "PanelD"]:
		var node := get_node_or_null(panel_name)
		if node:
			node.hide()
	if is_instance_valid(_im) and _im.action_dispatched.is_connected(_on_action_dispatched):
		_im.action_dispatched.disconnect(_on_action_dispatched)
