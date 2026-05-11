class_name MapCompletionTrigger
extends Node

var _triggered: bool = false

func _ready() -> void:
	EventBus.key_item_completed.connect(_on_key_item_completed)
	
	if KeyItemInventory.has(Constants.KEY_SECRET_MAP_CARD):
		call_deferred("_force_transition")

func _force_transition() -> void:
	var path := EpisodeController.zone_path_for_id(Constants.ZONE_EP2BRIDGE_SUNLIT)
	if not path.is_empty():
		EventBus.zone_change_requested.emit(path)

func _on_key_item_completed(key_item_id: StringName) -> void:
	if _triggered:
		return
	if key_item_id != Constants.KEY_SECRET_MAP_CARD:
		return
		
	_triggered = true
	
	# Pause input by telling InteractionManager (or get_tree().get_root().set_disable_input)
	# Safest way to block inputs in Godot is via unhandled_input block or viewport:
	var im := get_tree().current_scene.get_node_or_null("InteractionManager") as InteractionManager
	if im:
		im.set_busy(true)
		
	# Find MiniFrame to animate
	var hud := get_tree().current_scene.get_node_or_null("HUD")
	if hud:
		var mini_frame = hud.get_node_or_null("CanvasLayer/MiniFrame") # HUD usually adds it to a CanvasLayer
		if not mini_frame:
			# fallback search
			mini_frame = get_tree().current_scene.find_child("MiniFrame", true, false)
			
		if mini_frame and mini_frame.has_method("play_completion_animation"):
			mini_frame.play_completion_animation()
	
	# Request dialogue
	EventBus.dialogue_requested.emit(&"ep1.map_completed")
	
	# Wait for animation/dialogue to breathe
	await get_tree().create_timer(3.5).timeout
	
	if im:
		im.set_busy(false)
		
	# Transition to Bridge Zone
	var path := EpisodeController.zone_path_for_id(Constants.ZONE_EP2BRIDGE_SUNLIT)
	if not path.is_empty():
		EventBus.zone_change_requested.emit(path)
