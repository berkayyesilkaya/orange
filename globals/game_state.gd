class_name GameState
extends Node

var current_episode: StringName = &"ep1"
var current_zone: StringName = &"ep1.zone_1"
var completed_puzzles: Array[StringName] = []
var collected_fragments: Array[StringName] = []
var owned_key_items: Array[StringName] = []
var completed_key_items: Array[StringName] = []
# flags holds arbitrary boolean/value state (e.g. "episode_2_route_revealed")
var flags: Dictionary = {}


func reset() -> void:
	current_episode = &"ep1"
	current_zone = &"ep1.zone_1"
	completed_puzzles.clear()
	collected_fragments.clear()
	owned_key_items.clear()
	completed_key_items.clear()
	flags.clear()


# --- Puzzle helpers ---

func is_puzzle_completed(puzzle_id: StringName) -> bool:
	return completed_puzzles.has(puzzle_id)


func mark_puzzle_completed(puzzle_id: StringName) -> void:
	if not completed_puzzles.has(puzzle_id):
		completed_puzzles.append(puzzle_id)


# --- Fragment helpers ---

func is_fragment_collected(fragment_id: StringName) -> bool:
	return collected_fragments.has(fragment_id)


func mark_fragment_collected(fragment_id: StringName) -> void:
	if not collected_fragments.has(fragment_id):
		collected_fragments.append(fragment_id)


# --- Key item helpers ---

func is_key_item_owned(key_item_id: StringName) -> bool:
	return owned_key_items.has(key_item_id)


func grant_key_item(key_item_id: StringName) -> void:
	if not owned_key_items.has(key_item_id):
		owned_key_items.append(key_item_id)


func is_key_item_completed(key_item_id: StringName) -> bool:
	return completed_key_items.has(key_item_id)


func mark_key_item_completed(key_item_id: StringName) -> void:
	if not completed_key_items.has(key_item_id):
		completed_key_items.append(key_item_id)


# --- Flag helpers ---

func get_flag(key: String) -> Variant:
	return flags.get(key, null)


func set_flag(key: String, value: Variant) -> void:
	flags[key] = value
