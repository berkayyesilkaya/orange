class_name Ep2EndCard
extends Control

const _ORANGE_LINE  := "RUUU!"
const _ENGLISH_LINE := "The compass is ready. The river awaits.\n\nTo be continued."

@onready var _orange_line:    Label          = $CenterContainer/Content/OrangeLine
@onready var _english_line:   Label          = $CenterContainer/Content/EnglishLine
@onready var _play_again_btn: Button         = $CenterContainer/Content/PlayAgainButton
@onready var _confirm_panel:  PanelContainer = $ConfirmPanel
@onready var _yes_btn:        Button         = $ConfirmPanel/VBox/Buttons/YesButton
@onready var _no_btn:         Button         = $ConfirmPanel/VBox/Buttons/NoButton


func _ready() -> void:
	hide()
	_orange_line.text   = _ORANGE_LINE
	_english_line.text  = _ENGLISH_LINE
	_play_again_btn.pressed.connect(_on_play_again_pressed)
	_yes_btn.pressed.connect(_on_confirm_yes)
	_no_btn.pressed.connect(_on_confirm_no)
	_confirm_panel.hide()
	EventBus.key_item_completed.connect(_on_key_item_completed)


func _on_key_item_completed(key_item_id: StringName) -> void:
	if key_item_id != &"key.mixed_compass":
		return
	if EventBus.key_item_completed.is_connected(_on_key_item_completed):
		EventBus.key_item_completed.disconnect(_on_key_item_completed)
	await get_tree().create_timer(2.5).timeout
	EventBus.dialogue_requested.emit(&"ep2.compass_completed")
	_show_card()


func _show_card() -> void:
	show()
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_play_again_pressed() -> void:
	_confirm_panel.show()


func _on_confirm_yes() -> void:
	SaveSystem.wipe()
	var transition := get_tree().root.find_child("SoftTransition", true, false) as SoftTransition
	if transition:
		await transition.play_out()
	EventBus.zone_change_requested.emit(EpisodeController.zone_path_for_id(Constants.ZONE_EP1_1))


func _on_confirm_no() -> void:
	_confirm_panel.hide()
