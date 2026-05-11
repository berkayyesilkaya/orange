class_name WetBarkSymbolPuzzle
extends PuzzleBase

@export var expected_rotations: Array[int] = [1, 2, 3]
var current_rotations: Array[int] = [0, 0, 0]

func _ready() -> void:
	super._ready()
	var im := get_tree().current_scene.get_node_or_null("InteractionManager") as InteractionManager
	if im:
		im.action_dispatched.connect(_on_action_dispatched)

func _on_action_dispatched(interactable: Interactable) -> void:
	if _state == State.SOLVED:
		return
		
	var id := str(interactable.interactable_id)
	if not id.begins_with("ep1.wet_bark."):
		return
		
	var parts := id.split(".")
	if parts.size() != 3:
		return
		
	var idx := int(parts[2]) - 1
	if idx < 0 or idx >= current_rotations.size():
		return
		
	if _state == State.INACTIVE:
		start_puzzle()
		
	current_rotations[idx] = (current_rotations[idx] + 1) % 4
	
	# Animate the 90 degree rotation
	var sprite := interactable.get_node_or_null("Sprite2D") as Node2D
	if sprite:
		var tween := create_tween()
		var target_rot := current_rotations[idx] * (PI / 2.0)
		# Smooth wrap-around animation
		var current_rot := sprite.rotation
		if current_rotations[idx] == 0 and current_rot > PI:
			target_rot = PI * 2.0
			tween.tween_property(sprite, "rotation", target_rot, 0.2)
			tween.tween_callback(func(): sprite.rotation = 0.0)
		else:
			tween.tween_property(sprite, "rotation", target_rot, 0.2)
			
	_check_solution()

func _check_solution() -> void:
	for i in range(expected_rotations.size()):
		if current_rotations[i] != expected_rotations[i]:
			return
	
	mark_solved()
