class_name SunlitMapActivationPuzzle
extends PuzzleBase

# ---------------------------------------------------------------------------
# SunlitMapActivationPuzzle
#
# State machine:
#   INACTIVE → player taps MapCardSpot without the card → "no card" dialogue.
#   INACTIVE → player taps MapCardSpot with the card → start_puzzle() → ACTIVE.
#   ACTIVE   → player taps RotateLeft / RotateRight to turn the map sprite.
#   ACTIVE   → when _map_rotation_step == correct_step → mark_solved().
# ---------------------------------------------------------------------------

## The rotation step (0..3, each = 90°) that aligns map with sunbeam.
@export var correct_step: int = 1

var _map_rotation_step: int = 0
var _in_rotate_mode: bool = false

@onready var _map_sprite: Sprite2D = $MapCardSpot/MapSprite
@onready var _sunbeam: Sprite2D    = $Sunbeam


func _ready() -> void:
	super._ready()
	var im := get_tree().current_scene.get_node_or_null("InteractionManager") as InteractionManager
	if im:
		im.action_dispatched.connect(_on_action_dispatched)


func _on_action_dispatched(interactable: Interactable) -> void:
	if _state == State.SOLVED:
		return

	var id := str(interactable.interactable_id)

	# MapCardSpot — gate check
	if id == "ep2bridge.sunlit_map.spot":
		_handle_spot_tap()
		return

	# Rotation controls — only active in rotate-mode
	if not _in_rotate_mode:
		return

	if id == "ep2bridge.sunlit_map.rotate_left":
		_rotate_map(-1)
	elif id == "ep2bridge.sunlit_map.rotate_right":
		_rotate_map(1)


func _handle_spot_tap() -> void:
	if not KeyItemInventory.has(Constants.KEY_SECRET_MAP_CARD):
		EventBus.dialogue_requested.emit(&"ep2bridge.sunlit_map_no_card")
		return

	if _state == State.INACTIVE:
		start_puzzle()

	_in_rotate_mode = true
	# Reveal the rotation controls
	if has_node("RotateLeft"):
		$RotateLeft.show()
	if has_node("RotateRight"):
		$RotateRight.show()
	if has_node("MapCardSpot/MapSprite"):
		$MapCardSpot/MapSprite.show()


func _rotate_map(direction: int) -> void:
	_map_rotation_step = (_map_rotation_step + direction + 4) % 4

	if is_instance_valid(_map_sprite):
		var tween := create_tween()
		tween.tween_property(_map_sprite, "rotation", _map_rotation_step * (PI / 2.0), 0.25) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	if _map_rotation_step == correct_step:
		await get_tree().create_timer(0.35).timeout
		_complete()


func _complete() -> void:
	if _state == State.SOLVED:
		return

	# Persist the route-revealed flag before mark_solved (which also saves).
	GameState.set_flag("episode_2_route_revealed", true)
	EventBus.save_requested.emit(&"route_revealed")

	mark_solved()

	# Emit key_item_used so other systems (e.g. Episode 3 gate) can react.
	EventBus.key_item_used.emit(Constants.KEY_SECRET_MAP_CARD, &"sunlit_clearing")


func _on_already_solved() -> void:
	# If the puzzle was already completed on scene load, hide controls.
	if has_node("RotateLeft"):
		$RotateLeft.hide()
	if has_node("RotateRight"):
		$RotateRight.hide()
