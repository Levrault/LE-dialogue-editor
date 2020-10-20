# Manage editor interaction
extends Node

signal scene_cleared

enum Type { root, dialogue, choice, condition, signal_node }
enum FileState { new, opened, unsaved, saved, export_file }
enum Notification { idle, warning, error, success }

var current_state = FileState.new setget set_current_state
var previous_state = current_state
var locale := "en" setget set_locale
var graph_edit: GraphEdit = null

onready var root_node := load("res://src/Nodes/Root/RootNode.tscn")
onready var dialogue_node := load("res://src/Nodes/Dialogue/DialogueNode.tscn")
onready var choice_node := load("res://src/Nodes/Choice/ChoiceNode.tscn")
onready var condition_node := load("res://src/Nodes/Conditions/ConditionNode.tscn")
onready var signal_node := load("res://src/Nodes/Signal/SignalNode.tscn")


func _ready() -> void:
	locale = Config.values.locale.current


func reset() -> void:
	current_state = FileState.new
	self.locale = "en"

	Serialize.current_path = ""
	Store.json = {}
	Store.choices_node = {}
	Store.conditions_node = {}
	Store.signals_node = {}
	Store.dialogues_node = {}
	Store.dialogues_uuid = []

	for child in graph_edit.get_children():
		if child is GraphEditorNode:
			child.queue_free()

	yield(get_tree(), "idle_frame")
	self.call_deferred("emit_signal", "scene_cleared")


func type_to_string(value: int) -> String:
	var result := ''
	match value:
		Type.root:
			result = 'root'
		Type.dialogue:
			result = 'dialogue'
		Type.choice:
			result = 'choice'
		Type.condition:
			result = 'condition'
		Type.signal_node:
			result = 'signal'
	return result


func set_locale(value: String) -> void:
	locale = value
	Events.emit_signal("locale_changed", value)
	Config.values.locale.current = value
	Config.save(Config.values)


func set_current_state(new_state: int) -> void:
	previous_state = current_state
	current_state = new_state


func save_file() -> void:
	if (
		current_state == FileState.new
		or current_state == FileState.export_file
		or (current_state == FileState.unsaved and Serialize.current_path.empty())
	):
		Events.emit_signal("file_dialog_opened", 4)  # FileDialog.Mode.MODE_SAVE_FILE
		return
	if current_state == FileState.saved or current_state == FileState.unsaved:
		Serialize.save()
	return


func new_file() -> void:
	reset()
	get_tree().reload_current_scene()


func open_file() -> void:
	current_state = Editor.FileState.opened
	Events.emit_signal("file_dialog_opened", 0)  # FileDialog.Mode.MODE_OPEN_FILE


func open_folder() -> void:
	current_state = Editor.FileState.opened
	Events.emit_signal("file_dialog_opened", 2)  # FileDialog.Mode.MODE_OPEN_DIR
