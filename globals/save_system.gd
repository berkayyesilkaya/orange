class_name SaveSystem
extends Node

# ---------------------------------------------------------------------------
# SaveSystem — autoload singleton that reads/writes user://save.json.
#
# Rules (from prompts.md and ARCHITECTURE.md):
#  • This is the ONLY module that touches the save file.
#  • Other modules emit EventBus.save_requested; SaveSystem listens.
#  • save() must never be called per-frame — only on signal.
#  • load() is called once at startup by EpisodeController (P20).
#  • Mismatched version numbers refuse to load and log a warning.
#
# Save file shape (§5.4):
# {
#   "version": 1,
#   "current_episode": "ep1",
#   "current_zone": "ep1.zone_1",
#   "completed_puzzles": [...],
#   "collected_fragments": [...],
#   "owned_key_items": [],
#   "completed_key_items": [],
#   "flags": {}
# }
# ---------------------------------------------------------------------------

const SAVE_PATH  := "user://save.json"
const VERSION    := 1

## True while a save is pending this frame (debounce guard).
var _save_queued: bool = false


func _ready() -> void:
	EventBus.save_requested.connect(_on_save_requested)
	EventBus.fragment_collected.connect(_on_fragment_collected)


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Writes the current GameState to user://save.json.
func save() -> void:
	var data: Dictionary = {
		"version":            VERSION,
		"current_episode":    str(GameState.current_episode),
		"current_zone":       str(GameState.current_zone),
		"completed_puzzles":  _sn_array_to_strings(GameState.completed_puzzles),
		"collected_fragments": _sn_array_to_strings(GameState.collected_fragments),
		"owned_key_items":    _sn_array_to_strings(GameState.owned_key_items),
		"completed_key_items": _sn_array_to_strings(GameState.completed_key_items),
		"flags":              GameState.flags.duplicate(),
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: could not open '%s' for writing (error %d)." % [
			SAVE_PATH, FileAccess.get_open_error()])
		return

	file.store_string(JSON.stringify(data, "\t"))
	file.close()


## Reads user://save.json and applies values to GameState (and KeyItemInventory
## via GameState, which KeyItemInventory reads in its own _ready/_restore).
## Returns true on success, false if the file is missing or unreadable.
func load() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false  # First run — no save yet.

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveSystem: could not open '%s' for reading (error %d)." % [
			SAVE_PATH, FileAccess.get_open_error()])
		return false

	var text   := file.get_as_text()
	file.close()

	var json := JSON.new()
	var err  := json.parse(text)
	if err != OK:
		push_error("SaveSystem: JSON parse error in '%s': %s" % [SAVE_PATH, json.get_error_message()])
		return false

	if not json.data is Dictionary:
		push_error("SaveSystem: save file root is not a Dictionary.")
		return false

	var data: Dictionary = json.data

	# Version guard.
	var file_version: int = int(data.get("version", 0))
	if file_version != VERSION:
		push_warning("SaveSystem: save version mismatch (file=%d, expected=%d). Ignoring save." % [
			file_version, VERSION])
		return false

	# Apply to GameState.
	GameState.current_episode  = StringName(str(data.get("current_episode",  "ep1")))
	GameState.current_zone     = StringName(str(data.get("current_zone",     "ep1.zone_1")))
	GameState.completed_puzzles   = _strings_to_sn_array(data.get("completed_puzzles",   []))
	GameState.collected_fragments = _strings_to_sn_array(data.get("collected_fragments", []))
	GameState.owned_key_items     = _strings_to_sn_array(data.get("owned_key_items",     []))
	GameState.completed_key_items = _strings_to_sn_array(data.get("completed_key_items", []))

	var flags_raw = data.get("flags", {})
	if flags_raw is Dictionary:
		GameState.flags = flags_raw.duplicate()
	else:
		GameState.flags = {}

	return true


# ---------------------------------------------------------------------------
# Signal handlers
# ---------------------------------------------------------------------------

func _on_save_requested(_reason: StringName) -> void:
	# Debounce: if two signals fire in the same frame, save only once.
	if _save_queued:
		return
	_save_queued = true
	# Defer to end of frame so all state mutations in this frame are captured.
	call_deferred("_do_save")


func _on_fragment_collected(_fragment_id: StringName, _key_item_id: StringName) -> void:
	# fragment_collected is always followed by save_requested from FragmentPickup,
	# so this handler is intentionally empty — it exists to satisfy the prompt's
	# requirement that SaveSystem connects to both signals.  All saves go through
	# save_requested to keep C03 (single save path) intact.
	pass


func _do_save() -> void:
	_save_queued = false
	save()


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

## Converts Array[StringName] → Array[String] for JSON serialisation.
static func _sn_array_to_strings(arr: Array) -> Array:
	var out: Array = []
	for item in arr:
		out.append(str(item))
	return out


## Converts a JSON Array of strings → Array[StringName].
static func _strings_to_sn_array(arr: Variant) -> Array[StringName]:
	var out: Array[StringName] = []
	if arr is Array:
		for item in arr:
			out.append(StringName(str(item)))
	return out
