class_name EventBus
extends Node

# Global signals only — no logic (section 5.2)
signal puzzle_started(puzzle_id: StringName)
signal puzzle_solved(puzzle_id: StringName)
signal fragment_revealed(puzzle_id: StringName, fragment_id: StringName)
signal fragment_collected(fragment_id: StringName, key_item_id: StringName)
signal key_item_completed(key_item_id: StringName)
signal key_item_used(key_item_id: StringName, context: StringName)
signal dialogue_requested(line_id: StringName)
signal hint_requested()
signal zone_change_requested(zone_path: String)
signal save_requested(reason: StringName)
