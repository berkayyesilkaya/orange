extends Node

func _ready() -> void:
	print("EventBus.has_signal('puzzle_solved') = ", EventBus.has_signal("puzzle_solved"))
	print("GameState.completed_puzzles.size() = ", GameState.completed_puzzles.size())
