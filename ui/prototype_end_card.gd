class_name PrototypeEndCard
extends Control

# ---------------------------------------------------------------------------
# PrototypeEndCard — shown after key_item_used fires from the bridge puzzle.
#
# Design:
#  • Full-screen dark overlay with a centred poetic text line.
#  • "Restart Prototype" button → confirmation panel → wipes save, reloads zone 1.
#  • Layer 127 so it sits below SoftTransition (128) but above all gameplay.
# ---------------------------------------------------------------------------

const _END_LINE := "The forest remembers you.\n\nTo be continued."

@onready var _label:        Label        = $CenterContainer/VBox/EndLabel
@onready var _restart_btn:  Button       = $CenterContainer/VBox/RestartButton
@onready var _confirm_panel: PanelContainer = $ConfirmPanel
@onready var _yes_btn:      Button       = $ConfirmPanel/VBox/Buttons/YesButton
@onready var _no_btn:       Button       = $ConfirmPanel/VBox/Buttons/NoButton


func _ready() -> void:
	# Hidden until triggered.
	hide()

	_label.text = _END_LINE
	_restart_btn.pressed.connect(_on_restart_pressed)
	_yes_btn.pressed.connect(_on_confirm_yes)
	_no_btn.pressed.connect(_on_confirm_no)
	_confirm_panel.hide()

	EventBus.key_item_used.connect(_on_key_item_used)


func _on_key_item_used(key_item_id: StringName, context: StringName) -> void:
	if key_item_id != Constants.KEY_SECRET_MAP_CARD or context != &"sunlit_clearing":
		return

	# Disconnect so this fires only once.
	if EventBus.key_item_used.is_connected(_on_key_item_used):
		EventBus.key_item_used.disconnect(_on_key_item_used)

	# Small delay after the solved dialogue plays out.
	await get_tree().create_timer(2.5).timeout
	_show_card()


func _show_card() -> void:
	show()
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


# ---------------------------------------------------------------------------
# Restart flow
# ---------------------------------------------------------------------------

func _on_restart_pressed() -> void:
	_confirm_panel.show()


func _on_confirm_yes() -> void:
	# 1. Wipe save file.
	if FileAccess.file_exists(SaveSystem.SAVE_PATH):
		DirAccess.remove_absolute(SaveSystem.SAVE_PATH)

	# 2. Reset runtime state.
	GameState.reset()

	# 3. Fade out and reload zone 1.
	var transition := get_tree().root.find_child("SoftTransition", true, false) as SoftTransition
	if transition:
		await transition.play_out()

	var zone1_path: String = EpisodeController.zone_path_for_id(Constants.ZONE_EP1_1)
	EventBus.zone_change_requested.emit(zone1_path)


func _on_confirm_no() -> void:
	_confirm_panel.hide()
