class_name SoftTransition
extends CanvasLayer

# ---------------------------------------------------------------------------
# SoftTransition — reusable full-screen fade overlay.
#
# Usage (async):
#   await SoftTransition.play_out()   # fade to black
#   # ... change scene ...
#   await SoftTransition.play_in()    # fade back to clear
#
# play_in() is called automatically after every scene change that goes through
# EpisodeController._on_zone_change_requested().
# ---------------------------------------------------------------------------

const FADE_DURATION := 0.35

@onready var _rect: ColorRect = $FadeRect


func _ready() -> void:
	# Start fully transparent so the game is visible on first load.
	_rect.modulate.a = 0.0
	# Layer 128 puts us above all gameplay nodes but below system dialogs.
	layer = 128


# Fade the screen TO black.  Caller awaits this to know the screen is hidden.
func play_out() -> void:
	_rect.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 1.0, FADE_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished


# Fade the screen FROM black back to clear.
# Always runs to completion even if called redundantly, to prevent stuck overlays.
func play_in() -> void:
	_rect.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(_rect, "modulate:a", 0.0, FADE_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
