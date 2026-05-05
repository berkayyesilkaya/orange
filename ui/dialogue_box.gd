class_name DialogueBox
extends PanelContainer

@onready var _orange_line: Label = $VBoxContainer/OrangeLine
@onready var _english_line: Label = $VBoxContainer/EnglishLine

var _lines: Dictionary = {}
var _tween: Tween = null


func _ready() -> void:
	hide()
	_load_dialogue()
	EventBus.dialogue_requested.connect(show_line)


func show_line(line_id: StringName, duration: float = 3.0) -> void:
	var entry: Dictionary = _lines.get(str(line_id), {})
	if entry.is_empty():
		push_warning("DialogueBox: missing key '%s'" % line_id)
		return

	_orange_line.text = entry.get("orange", "")
	_english_line.text = entry.get("english", "")

	if _tween:
		_tween.kill()

	modulate.a = 0.0
	show()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.3)
	_tween.tween_interval(duration)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	_tween.tween_callback(hide)


func show_text(text: String, duration: float = 3.0) -> void:
	_orange_line.text = ""
	_english_line.text = text

	if _tween:
		_tween.kill()

	modulate.a = 0.0
	show()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.3)
	_tween.tween_interval(duration)
	_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	_tween.tween_callback(hide)


func _load_dialogue() -> void:
	var episode: String = str(GameState.current_episode)
	var path := "res://data/dialogue/%s.json" % episode
	if not FileAccess.file_exists(path):
		push_warning("DialogueBox: no dialogue file at '%s'" % path)
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_warning("DialogueBox: cannot open '%s'" % path)
		return
	var raw := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(raw) != OK:
		push_warning("DialogueBox: JSON parse error in '%s'" % path)
		return
	if json.data is Dictionary:
		_lines = json.data
