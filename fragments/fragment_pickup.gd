class_name FragmentPickup
extends Interactable

# ---------------------------------------------------------------------------
# FragmentPickup — a pre-placed, initially hidden pickup node.
#
# Design decisions:
#  • Extends Interactable so InteractionManager (P09) detects taps and drives
#    the tap → walk → ActionButton flow without any new infrastructure.
#  • The InteractionManager's `action_dispatched` signal carries the tapped
#    Interactable; the zone connects it to `_on_action_dispatched` on each
#    FragmentPickup (or a shared handler) so "Collect" is processed here.
#  • Starts hidden; becomes visible only when EventBus.fragment_revealed fires
#    with a matching fragment_id.
#  • Auto-collection is explicitly forbidden (prompts clarification C04).
# ---------------------------------------------------------------------------

@export var reward: FragmentReward = null

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	# Fix action label regardless of Inspector value.
	action_label = "Collect"

	# Start hidden — invisible until fragment_revealed matches us.
	hide()

	if reward == null:
		push_warning("FragmentPickup (%s): `reward` is null — node will never appear." % name)
		return

	# Sync interactable_id from reward so InteractionManager's label lookup and
	# dispatch work without manual Inspector entry.
	if interactable_id == &"":
		interactable_id = reward.fragment_id

	# If already collected (e.g. scene reloaded from save), stay permanently hidden.
	if GameState.is_fragment_collected(reward.fragment_id):
		return

	# Subscribe to the global reveal signal.
	EventBus.fragment_revealed.connect(_on_fragment_revealed)


# ---------------------------------------------------------------------------
# Called by the zone's InteractionManager via `action_dispatched` signal.
# Zones should connect: interaction_manager.action_dispatched.connect(pickup._on_action_dispatched)
# ---------------------------------------------------------------------------

func _on_action_dispatched(interactable: Interactable) -> void:
	if interactable != self:
		return
	_collect()


# ---------------------------------------------------------------------------
# EventBus handler — appears when our fragment is revealed
# ---------------------------------------------------------------------------

func _on_fragment_revealed(_puzzle_id: StringName, fragment_id: StringName) -> void:
	if reward == null or fragment_id != reward.fragment_id:
		return

	# One-shot: disconnect after the first matching reveal.
	if EventBus.fragment_revealed.is_connected(_on_fragment_revealed):
		EventBus.fragment_revealed.disconnect(_on_fragment_revealed)

	_appear()


# ---------------------------------------------------------------------------
# Visual appearance
# ---------------------------------------------------------------------------

func _appear() -> void:
	show()

	if is_instance_valid(_anim) and _anim.has_animation("appear"):
		_anim.play("appear")
		return

	# Fallback soft fade-in followed by idle float loop.
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	tween.tween_callback(_start_float_loop)


func _start_float_loop() -> void:
	if is_instance_valid(_anim) and _anim.has_animation("float"):
		_anim.play("float")


# ---------------------------------------------------------------------------
# Collection
# ---------------------------------------------------------------------------

func _collect() -> void:
	if reward == null:
		return

	# 1. Runtime state — SaveSystem (P19) handles disk write.
	GameState.mark_fragment_collected(reward.fragment_id)

	# 2. Global signal: drives MiniFrame (P17) and KeyItemInventory (P18).
	EventBus.fragment_collected.emit(reward.fragment_id, reward.key_item_id)

	# 3. Request save (SaveSystem listens to save_requested — P19).
	EventBus.save_requested.emit(&"fragment_collected")

	# 4. Remove pickup from world.
	queue_free()
