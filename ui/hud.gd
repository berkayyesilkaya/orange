class_name Hud
extends CanvasLayer

@onready var _action_button_slot: Control = $Bottom/ActionButtonSlot
@onready var _dialogue_box_slot: Control = $Bottom/DialogueBoxSlot
@onready var _hint_button_slot: Control = $TopRight/HintButtonSlot
@onready var _mini_frame_slot: Control = $TopLeft/MiniFrameSlot
@onready var _floating_labels: Control = $FloatingLabels


func mount_action_button(node: Node) -> void:
	_reparent_into(_action_button_slot, node)


func mount_dialogue_box(node: Node) -> void:
	_reparent_into(_dialogue_box_slot, node)


func mount_hint_button(node: Node) -> void:
	_reparent_into(_hint_button_slot, node)


func mount_mini_frame(node: Node) -> void:
	_reparent_into(_mini_frame_slot, node)


func add_floating_label(node: Node) -> void:
	_floating_labels.add_child(node)


func _reparent_into(slot: Control, node: Node) -> void:
	if node.get_parent():
		node.reparent(slot)
	else:
		slot.add_child(node)
