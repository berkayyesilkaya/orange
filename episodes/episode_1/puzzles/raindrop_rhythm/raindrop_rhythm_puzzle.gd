class_name RaindropRhythmPuzzle
extends PuzzleBase

@export var pattern: Array[StringName] = [&"leaf", &"puddle", &"leaf", &"log"]
var current_progress: Array[StringName] = []

@onready var demo_timer: Timer = $DemoTimer

func _ready() -> void:
	super._ready()
	var im := get_tree().current_scene.get_node_or_null("InteractionManager") as InteractionManager
	if im:
		im.action_dispatched.connect(_on_action_dispatched)

func _on_action_dispatched(interactable: Interactable) -> void:
	if _state == State.SOLVED:
		return
		
	var id := str(interactable.interactable_id)
	if not id.begins_with("ep1.raindrop."):
		return
		
	var parts := id.split(".")
	if parts.size() != 3:
		return
		
	var chosen_obj := StringName(parts[2])
	
	if _state == State.INACTIVE:
		start_puzzle()
		
	current_progress.append(chosen_obj)
	
	# Validate prefix
	var valid := true
	for i in range(current_progress.size()):
		if current_progress[i] != pattern[i]:
			valid = false
			break
			
	if not valid:
		current_progress.clear()
		if definition and definition.hint_text_key != &"":
			EventBus.dialogue_requested.emit(definition.hint_text_key)
		return
		
	# Match so far
	if current_progress.size() == pattern.size():
		demo_timer.stop()
		mark_solved()

func _on_demo_timer_timeout() -> void:
	if _state == State.SOLVED:
		return
	_play_demo_sequence()

func _play_demo_sequence() -> void:
	# Flash the objects in sequence to demonstrate the pattern.
	var tween := create_tween()
	var time_offset := 0.0
	for item_name in pattern:
		var interactable := get_node_or_null("Obj" + item_name.capitalize()) as Interactable
		if interactable:
			var sprite := interactable.get_node_or_null("Sprite2D") as Sprite2D
			if sprite:
				# Flash color
				tween.tween_property(sprite, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.2).set_delay(time_offset)
				tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
		time_offset += 0.8 # space out flashes
