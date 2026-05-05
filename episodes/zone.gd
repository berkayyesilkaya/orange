class_name Zone
extends Node2D

@export var zone_id: StringName = &""


func _ready() -> void:
	if zone_id != &"":
		GameState.current_zone = zone_id
	_setup_hud()


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
