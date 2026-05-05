class_name FloatingLabel
extends Control

@onready var _label: Label = $Label


func show_label(text: String, world_pos: Vector2) -> void:
	_label.text = text
	call_deferred("_position_and_animate", world_pos)


func _position_and_animate(world_pos: Vector2) -> void:
	var screen_pos := get_viewport().get_canvas_transform() * world_pos
	global_position = screen_pos - Vector2(_label.size.x * 0.5, _label.size.y + 12.0)

	modulate.a = 0.0
	show()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	tween.tween_interval(1.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)
