class_name HintButton
extends TextureButton

const _HINT_PATHS: Array[String] = [
	"res://data/hints/episode_1.json",
	"res://data/hints/episode_2_bridge.json",
]

var _current_puzzle_id: StringName = &""
var _hint_data: Dictionary = {}
var _dialogue_box: DialogueBox = null


func _ready() -> void:
	_load_hint_data()
	_set_active(false)
	pressed.connect(_on_pressed)
	EventBus.puzzle_started.connect(_on_puzzle_started)
	EventBus.puzzle_solved.connect(_on_puzzle_solved)
	EventBus.hint_requested.connect(_on_hint_requested)


func set_dialogue_box(box: DialogueBox) -> void:
	_dialogue_box = box


func hint_for(puzzle_id: StringName) -> String:
	return _hint_data.get(str(puzzle_id), "")


func _on_pressed() -> void:
	EventBus.hint_requested.emit()


func _on_hint_requested() -> void:
	if _current_puzzle_id == &"" or not _dialogue_box:
		return
	var text := hint_for(_current_puzzle_id)
	if text.is_empty():
		push_warning("HintButton: no hint for puzzle '%s'" % _current_puzzle_id)
		return
	_dialogue_box.show_text(text, 4.0)


func _on_puzzle_started(puzzle_id: StringName) -> void:
	_current_puzzle_id = puzzle_id
	_set_active(true)


func _on_puzzle_solved(_puzzle_id: StringName) -> void:
	_current_puzzle_id = &""
	_set_active(false)


func _set_active(active: bool) -> void:
	disabled = not active
	modulate.a = 1.0 if active else 0.35


func _load_hint_data() -> void:
	for path in _HINT_PATHS:
		if not FileAccess.file_exists(path):
			continue
		var file := FileAccess.open(path, FileAccess.READ)
		if not file:
			push_warning("HintButton: cannot open '%s'" % path)
			continue
		var raw := file.get_as_text()
		file.close()
		var json := JSON.new()
		if json.parse(raw) != OK:
			push_warning("HintButton: JSON parse error in '%s'" % path)
			continue
		if json.data is Dictionary:
			_hint_data.merge(json.data, true)
