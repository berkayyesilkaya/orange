class_name MushroomPathPuzzle
extends PuzzleBase

var expected_order: Array[int] = [1, 2, 3, 4, 5]
var current_progress: Array[int] = []

func _ready() -> void:
	super._ready()
	# Connect to InteractionManager to hear clicks on our specific clusters.
	# We use action_dispatched instead of puzzle_started to track sequence.
	var im := get_tree().current_scene.get_node_or_null("InteractionManager") as InteractionManager
	if im:
		im.action_dispatched.connect(_on_action_dispatched)

func _on_action_dispatched(interactable: Interactable) -> void:
	if _state == State.SOLVED:
		return
		
	var id := str(interactable.interactable_id)
	if not id.begins_with("ep1.mushroom_path."):
		return
		
	var parts := id.split(".")
	if parts.size() != 3:
		return
		
	var idx := int(parts[2])
	
	if _state == State.INACTIVE:
		start_puzzle()
		
	current_progress.append(idx)
	
	# Validate prefix
	var valid := true
	for i in range(current_progress.size()):
		if current_progress[i] != expected_order[i]:
			valid = false
			break
			
	if not valid:
		current_progress.clear()
		if definition and definition.hint_text_key != &"":
			EventBus.dialogue_requested.emit(definition.hint_text_key)
		return
		
	# Match so far
	if current_progress.size() == expected_order.size():
		mark_solved()
