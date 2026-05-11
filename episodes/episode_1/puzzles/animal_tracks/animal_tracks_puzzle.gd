class_name AnimalTracksPuzzle
extends PuzzleBase

@export var correct_trail: StringName = &"deer"

func _ready() -> void:
	super._ready()
	var im := get_tree().current_scene.get_node_or_null("InteractionManager") as InteractionManager
	if im:
		im.action_dispatched.connect(_on_action_dispatched)

func _on_action_dispatched(interactable: Interactable) -> void:
	if _state == State.SOLVED:
		return
		
	var id := str(interactable.interactable_id)
	if not id.begins_with("ep1.animal_tracks."):
		return
		
	var parts := id.split(".")
	if parts.size() != 3:
		return
		
	var chosen_trail := StringName(parts[2])
	
	if _state == State.INACTIVE:
		start_puzzle()
		
	if chosen_trail == correct_trail:
		mark_solved()
	else:
		# Different gentle dialogues per wrong animal
		var wrong_dialogue := StringName("ep1.animal_tracks.wrong_" + str(chosen_trail))
		EventBus.dialogue_requested.emit(wrong_dialogue)
