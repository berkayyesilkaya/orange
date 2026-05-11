class_name ZoneExit
extends Area2D

# ---------------------------------------------------------------------------
# ZoneExit — an Area2D trigger that changes scenes when Orange enters it.
# Place one at each zone boundary; set `target_zone_id` in the Inspector.
# EpisodeController converts the zone id to a file path.
# ---------------------------------------------------------------------------

## The zone_id of the destination zone (e.g. &"ep1.zone_2").
@export var target_zone_id: StringName = &""


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not (body is OrangeCharacter):
		return
	if target_zone_id == &"":
		push_warning("ZoneExit (%s): target_zone_id is empty." % name)
		return

	var path := EpisodeController.zone_path_for_id(target_zone_id)
	if path.is_empty():
		push_error("ZoneExit (%s): no path registered for zone id '%s'." % [name, target_zone_id])
		return

	EventBus.zone_change_requested.emit(path)
