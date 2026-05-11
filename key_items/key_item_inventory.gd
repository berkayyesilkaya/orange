class_name KeyItemInventory
extends Node

# ---------------------------------------------------------------------------
# KeyItemInventory — autoload singleton (registered as "KeyItemInventory").
#
# Intentionally tiny: only the two fixed story key items are supported.
# There is no "open inventory" menu — the system is driven entirely by
# EventBus signals and read by other systems (e.g. Episode 2 bridge gate).
#
# Registry maps key_item_id → resource path so items are loaded on-demand
# rather than pre-loading everything at startup.
# ---------------------------------------------------------------------------

const _REGISTRY: Dictionary = {
	&"key.secret_map_card": "res://key_items/secret_map_card.tres",
	&"key.mixed_compass":   "res://key_items/mixed_compass.tres",
}

## Runtime list of owned KeyItem resources.
var owned: Array[KeyItem] = []


func _ready() -> void:
	EventBus.key_item_completed.connect(_on_key_item_completed)
	_restore_from_state()


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Add a key item to the owned list.
## Idempotent: calling twice with the same item is a no-op.
func grant(item: KeyItem) -> void:
	if item == null:
		push_warning("KeyItemInventory.grant: item is null.")
		return
	if has(item.key_item_id):
		return  # Already owned.
	owned.append(item)


## Returns true if the item with the given id is owned.
func has(id: StringName) -> bool:
	for item: KeyItem in owned:
		if item.key_item_id == id:
			return true
	return false


## Returns the owned KeyItem with the given id, or null if not owned.
func get_item(id: StringName) -> KeyItem:
	for item: KeyItem in owned:
		if item.key_item_id == id:
			return item
	return null


## Emits key_item_used if the item is owned; silent no-op otherwise.
func use(id: StringName, context: StringName) -> void:
	if not has(id):
		push_warning("KeyItemInventory.use: item '%s' not owned." % id)
		return
	EventBus.key_item_used.emit(id, context)


# ---------------------------------------------------------------------------
# EventBus handler
# ---------------------------------------------------------------------------

func _on_key_item_completed(key_item_id: StringName) -> void:
	var item := _load_item(key_item_id)
	if item == null:
		push_warning("KeyItemInventory: unknown key_item_id '%s'." % key_item_id)
		return

	# Grant into runtime inventory (idempotent).
	grant(item)

	# Persist to GameState (SaveSystem writes to disk — P19).
	GameState.mark_key_item_completed(key_item_id)

	# Request a save.
	EventBus.save_requested.emit(&"key_item_completed")


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

## Loads a KeyItem resource from the registry by id.
func _load_item(id: StringName) -> KeyItem:
	var path: String = _REGISTRY.get(id, "")
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		push_error("KeyItemInventory: resource not found at '%s'." % path)
		return null
	return load(path) as KeyItem


## Restores owned items from GameState after a load (called in _ready).
func _restore_from_state() -> void:
	for id: StringName in GameState.completed_key_items:
		var item := _load_item(id)
		if item:
			grant(item)
