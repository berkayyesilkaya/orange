class_name MiniFrame
extends Control

# ---------------------------------------------------------------------------
# MiniFrame — top-left progress widget for the active key item.
#
# Slot filling is driven by FragmentReward.frame_slot (0-based) so fragments
# arriving out of order always fill the correct cell.
#
# Usage:
#   1. Mount via Hud.mount_mini_frame(instance).
#   2. Call set_key_item(item) to configure slots and restore existing state.
# ---------------------------------------------------------------------------

const MAX_SLOTS: int = 4
const EMPTY_SLOT_COLOR  := Color(0.18, 0.18, 0.22, 0.7)
const FILL_FLASH_COLOR  := Color(1.0, 0.95, 0.7, 1.0)

var _key_item: KeyItem = null
var _slot_nodes: Array[TextureRect] = []
# Parallel bool array — true once a slot has been filled (used for completion check).
var _slot_filled: Array[bool] = []
var _frame_image: Texture2D = null

@onready var _frame_border: TextureRect  = $FrameBorder
@onready var _slots_container: GridContainer = $SlotsContainer


func _ready() -> void:
	EventBus.fragment_collected.connect(_on_fragment_collected)


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Configure (or re-configure) the frame for a new key item.
## Safe to call after load; reads GameState.collected_fragments to restore state.
func set_key_item(item: KeyItem) -> void:
	if item == null:
		push_warning("MiniFrame: set_key_item called with null.")
		return
	_key_item = item
	_build_slots()
	_restore_from_state()


# ---------------------------------------------------------------------------
# Slot construction
# ---------------------------------------------------------------------------

func _build_slots() -> void:
	for child in _slots_container.get_children():
		child.queue_free()
	_slot_nodes.clear()
	_slot_filled.clear()

	if _key_item == null:
		return

	var total: int = clampi(_key_item.total_fragments, 1, MAX_SLOTS)
	_slots_container.columns = total

	_frame_image = null
	if not _key_item.frame_image_path.is_empty() and ResourceLoader.exists(_key_item.frame_image_path):
		_frame_image = load(_key_item.frame_image_path) as Texture2D

	for i: int in total:
		var slot := TextureRect.new()
		slot.name = "Slot%d" % i
		slot.custom_minimum_size = Vector2(32, 32)
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.self_modulate = EMPTY_SLOT_COLOR
		_slots_container.add_child(slot)
		_slot_nodes.append(slot)
		_slot_filled.append(false)


func _restore_from_state() -> void:
	if _key_item == null:
		return
	for frag_id: StringName in GameState.collected_fragments:
		var idx := _slot_index_for_fragment(frag_id)
		if idx >= 0:
			_fill_slot_instant(idx)


# ---------------------------------------------------------------------------
# EventBus handler
# ---------------------------------------------------------------------------

func _on_fragment_collected(fragment_id: StringName, key_item_id: StringName) -> void:
	if _key_item == null or key_item_id != _key_item.key_item_id:
		return
	var idx := _slot_index_for_fragment(fragment_id)
	if idx < 0:
		return
	_fill_slot_animated(idx)
	_check_completion()


# ---------------------------------------------------------------------------
# Fragment → slot resolution
# ---------------------------------------------------------------------------

const _EPISODE_DEF_PATHS: Dictionary = {
	"ep1":       "res://episodes/episode_1/definitions",
	"ep2bridge": "res://episodes/episode_2_bridge/definitions",
}

## Looks up the frame_slot for a given fragment_id by scanning PuzzleDefinition
## resources in the active episode's definitions folder.  The set is always ≤4.
func _slot_index_for_fragment(fragment_id: StringName) -> int:
	var episode: String = str(GameState.current_episode)
	var def_path: String = _EPISODE_DEF_PATHS.get(episode, "")
	if def_path.is_empty():
		return -1
	var dir := DirAccess.open(def_path)
	if dir == null:
		return -1
	dir.list_dir_begin()
	var fname: String = dir.get_next()
	while fname != "":
		if fname.ends_with(".tres"):
			var res := load(def_path + "/" + fname)
			if res is PuzzleDefinition:
				var pd := res as PuzzleDefinition
				if pd.fragment_reward != null and pd.fragment_reward.fragment_id == fragment_id:
					dir.list_dir_end()
					return pd.fragment_reward.frame_slot
		fname = dir.get_next()
	dir.list_dir_end()
	return -1


# ---------------------------------------------------------------------------
# Slot fill helpers
# ---------------------------------------------------------------------------

func _fill_slot_instant(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= _slot_nodes.size():
		return
	_slot_filled[slot_index] = true
	var slot := _slot_nodes[slot_index]
	if _frame_image:
		slot.texture = _frame_image
	slot.self_modulate = Color.WHITE


func _fill_slot_animated(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= _slot_nodes.size():
		return
	if _slot_filled[slot_index]:
		return  # Already filled — idempotent.
	_slot_filled[slot_index] = true
	var slot := _slot_nodes[slot_index]
	if _frame_image:
		slot.texture = _frame_image
	slot.self_modulate = FILL_FLASH_COLOR
	var tween := create_tween()
	tween.tween_property(slot, "self_modulate", Color.WHITE, 0.5)


func _check_completion() -> void:
	if _key_item == null:
		return
	var filled := _slot_filled.filter(func(v: bool) -> bool: return v)
	if filled.size() >= _key_item.total_fragments:
		EventBus.key_item_completed.emit(_key_item.key_item_id)

# ---------------------------------------------------------------------------
# Cinematic Completion
# ---------------------------------------------------------------------------

func play_completion_animation() -> void:
	pivot_offset = size / 2.0
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.0)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
