# Manage editor interaction
extends Node

signal scene_cleared

enum Type { root, dialogue, choice, condition, signal_node }
enum Notification { idle, warning, error, success }

var workspace := {}
var locale := "en" setget set_locale
var graph_edit: GraphEdit = null
var load_last_opened_file := true
var is_loading := false

onready var root_node := load("res://src/Nodes/Root/RootNode.tscn")
onready var dialogue_node := load("res://src/Nodes/Dialogue/DialogueNode.tscn")
onready var choice_node := load("res://src/Nodes/Choice/ChoiceNode.tscn")
onready var condition_node := load("res://src/Nodes/Conditions/ConditionNode.tscn")
onready var signal_node := load("res://src/Nodes/Signal/SignalNode.tscn")


func _ready() -> void:
	locale = Config.values.locale.current


func reset() -> void:
	self.is_loading = true
	for child in graph_edit.get_children():
		if not child is GraphEditorNode:
			continue

		if child != Store.root_node:
			child.on_Close_request()
		child.call_deferred("queue_free")

	Serialize.current_path = ""
	Store.json = {}
	Store.root_node = null
	Store.choices_node = {}
	Store.conditions_node = {}
	Store.signals_node = {}
	Store.dialogues_node = {}
	Store.dialogues_uuid = []

	yield(get_tree(), "idle_frame")
	self.is_loading = false
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
	Config.save(Config.values, Editor.workspace.folder)


func save_file() -> void:
	if FileManager.should_be_registred():
		Events.emit_signal("file_dialog_opened", 4)  # FileDialog.Mode.MODE_SAVE_FILE
		return

	Serialize.current_path = FileManager.edited_file.path
	Serialize.save()
	FileManager.pristine()


func new_file() -> void:
	FileManager.cache_file()
	reset()
	load_last_opened_file = false
	get_tree().reload_current_scene()
	yield(get_tree(), "idle_frame")
	Events.emit_signal("workspace_unsaved_file_added")
	FileManager.state = FileManager.State.unregistred_pristine


func open_file() -> void:
	# TODO: should open and add the file to workspace
	FileManager.state = FileManager.State.registred_pristine
	Events.emit_signal("file_dialog_opened", 0)  # FileDialog.Mode.MODE_OPEN_FILE


func load_welcome_screen() -> void:
	reset()
	get_tree().change_scene("res://src/WelcomePage/WelcomePage.tscn")
	FileManager.clear()
	yield(FileManager, "cache_cleared")
	load_last_opened_file = true


func import_image(path: String, size: Vector2) -> ImageTexture:
	var texture := ImageTexture.new()
	var image := Image.new()

	var err = image.load(path.replace(Constant.RESOURCE, Editor.workspace.resource))
	assert(err == OK)

	texture.create_from_image(image, 0)
	texture.set_size_override(size)

	return texture
