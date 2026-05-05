class_name Interactable
extends Area2D

signal interaction_triggered(interactable: Interactable)

@export var interactable_id: StringName = &""
@export var display_label: String = ""
@export var action_label: String = "Inspect"
## World-space offset from this node's origin where Orange should stand.
@export var interaction_position: Vector2 = Vector2.ZERO


func request_interaction(orange: OrangeCharacter) -> void:
	orange.move_to(global_position + interaction_position)
	await orange.arrived_at_target
	interaction_triggered.emit(self)
