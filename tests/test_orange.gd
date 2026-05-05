extends Node2D

@onready var orange: OrangeCharacter = $OrangeCharacter


func _ready() -> void:
	orange.arrived_at_target.connect(_on_arrived)
	await get_tree().create_timer(1.0).timeout
	print("[TestOrange] Calling move_to(200, 100) — is_moving before: ", orange.is_moving)
	orange.move_to(Vector2(200.0, 100.0))


func _on_arrived() -> void:
	print("[TestOrange] arrived_at_target emitted — is_moving after: ", orange.is_moving)
