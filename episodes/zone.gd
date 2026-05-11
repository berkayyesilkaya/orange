class_name Zone
extends Node2D

@export var zone_id: StringName = &""


func _ready() -> void:
	if zone_id != &"":
		GameState.current_zone = zone_id
		# Keep current_episode in sync with the active zone so systems that read
		# it (dialogue_box, hint_button, mini_frame) see the correct episode
		# without requiring EpisodeController to call set_episode() explicitly.
		if str(zone_id).begins_with("ep2bridge"):
			GameState.current_episode = &"ep2bridge"
		elif str(zone_id).begins_with("ep1"):
			GameState.current_episode = &"ep1"
	_setup_hud()


# Free tap-to-move: any tap not consumed by InteractionManager moves Orange.
# InteractionManager calls set_input_as_handled() when it finds an interactable,
# so this handler only fires for taps on empty space.
func _unhandled_input(event: InputEvent) -> void:
	if not _is_tap_press(event):
		return
	var orange := get_node_or_null("OrangeCharacter") as OrangeCharacter
	if not is_instance_valid(orange):
		return
	var screen_pos: Vector2
	if event is InputEventScreenTouch:
		screen_pos = (event as InputEventScreenTouch).position
	else:
		screen_pos = (event as InputEventMouseButton).position
	var world_pos := get_viewport().get_canvas_transform().affine_inverse() * screen_pos
	orange.move_to(world_pos)
	get_viewport().set_input_as_handled()


static func _is_tap_press(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		return mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed
	return false


# Wires HUD slots with sibling ActionButton and InteractionManager if present.
# This keeps zone scenes self-contained without any hardcoded paths.
func _setup_hud() -> void:
	var hud := get_node_or_null("HUD") as Hud
	if not hud:
		return
	var action_button := get_node_or_null("ActionButton") as ActionButton
	var interaction_manager := get_node_or_null("InteractionManager") as InteractionManager
	var dialogue_box := get_node_or_null("DialogueBox") as DialogueBox
	var hint_button := get_node_or_null("HintButton") as HintButton
	if action_button:
		hud.mount_action_button(action_button)
	if action_button and interaction_manager:
		interaction_manager.set_action_button(action_button)
	if interaction_manager and hud:
		interaction_manager.set_hud(hud)
	if dialogue_box:
		hud.mount_dialogue_box(dialogue_box)
	if hint_button:
		hud.mount_hint_button(hint_button)
	if hint_button and dialogue_box:
		hint_button.set_dialogue_box(dialogue_box)
