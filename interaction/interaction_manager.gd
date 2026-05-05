class_name InteractionManager
extends Node

## Emitted for non-puzzle interactables when the action button is pressed.
signal action_dispatched(interactable: Interactable)

const _FLOATING_LABEL_SCENE := preload("res://ui/floating_label.tscn")

@export var orange: OrangeCharacter

var _action_button: ActionButton = null
var _hud: Hud = null
var _label_data: Dictionary = {}
var _is_busy: bool = false


func _ready() -> void:
	_load_label_data()


func set_hud(hud: Hud) -> void:
	_hud = hud


# Called by the zone or HUD to wire up the shared ActionButton.
func set_action_button(button: ActionButton) -> void:
	if _action_button and _action_button.confirmed.is_connected(_on_action_confirmed):
		_action_button.confirmed.disconnect(_on_action_confirmed)
	_action_button = button
	_action_button.confirmed.connect(_on_action_confirmed)
	_action_button.hide_button()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_tap_press(event):
		return

	var tapped := _get_interactable_at(_event_screen_pos(event))

	if tapped:
		# Consume so WalkableArea (P05) never moves Orange toward an interactable.
		get_viewport().set_input_as_handled()
		if not _is_busy:
			_handle_tap(tapped)
		return

	# Tap missed every interactable — hide button but leave event for WalkableArea.
	if _action_button and _action_button.visible:
		_action_button.hide_button()


func _handle_tap(interactable: Interactable) -> void:
	_is_busy = true
	_show_floating_label(interactable)
	if _action_button:
		_action_button.hide_button()
	if is_instance_valid(orange):
		await interactable.request_interaction(orange)
	if not is_instance_valid(self):  # guard against scene change during await
		return
	if is_instance_valid(interactable) and _action_button:
		_action_button.show_for(interactable)
	_is_busy = false


func _on_action_confirmed(interactable: Interactable) -> void:
	if _action_button:
		_action_button.hide_button()
	_dispatch_action(interactable)


func _dispatch_action(interactable: Interactable) -> void:
	var id := interactable.interactable_id
	# Puzzle interactables: delegate lifecycle to PuzzleBase via EventBus (see C02).
	if (id == Constants.PUZZLE_MUSHROOM_PATH or
			id == Constants.PUZZLE_ANIMAL_TRACKS or
			id == Constants.PUZZLE_RAINDROP_RHYTHM or
			id == Constants.PUZZLE_WET_BARK_SYMBOL or
			id == Constants.PUZZLE_SUNLIT_MAP):
		EventBus.puzzle_started.emit(id)
	else:
		action_dispatched.emit(interactable)


func _get_interactable_at(screen_pos: Vector2) -> Interactable:
	var world_pos := get_viewport().get_canvas_transform().affine_inverse() * screen_pos
	var space := get_viewport().get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = world_pos
	params.collide_with_areas = true
	params.collide_with_bodies = false
	for result in space.intersect_point(params):
		if result["collider"] is Interactable:
			return result["collider"] as Interactable
	return null


static func _is_tap_press(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		return mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed
	return false


static func _event_screen_pos(event: InputEvent) -> Vector2:
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).position
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).position
	return Vector2.ZERO


func _show_floating_label(interactable: Interactable) -> void:
	if not _hud:
		return
	var text: String = _label_data.get(str(interactable.interactable_id), interactable.display_label)
	if text.is_empty():
		return
	var label := _FLOATING_LABEL_SCENE.instantiate() as FloatingLabel
	_hud.add_floating_label(label)
	label.show_label(text, interactable.global_position)


func _load_label_data() -> void:
	var episode: String = str(GameState.current_episode)
	var path := "res://data/floating_labels/%s.json" % episode
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_warning("InteractionManager: JSON parse error in '%s'" % path)
		return
	file.close()
	if json.data is Dictionary:
		_label_data = json.data
