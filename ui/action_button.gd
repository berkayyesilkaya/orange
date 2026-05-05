class_name ActionButton
extends Control

## Emitted when the player presses the button; carries the active interactable.
signal confirmed(interactable: Interactable)

@onready var _texture_button: TextureButton = $TextureButton
@onready var _label: Label = $TextureButton/Label

var _current_interactable: Interactable = null


func _ready() -> void:
	hide()
	_texture_button.pressed.connect(_on_pressed)


func show_for(interactable: Interactable) -> void:
	_current_interactable = interactable
	_label.text = interactable.action_label
	show()


func hide_button() -> void:
	_current_interactable = null
	hide()


func _on_pressed() -> void:
	if _current_interactable:
		confirmed.emit(_current_interactable)
