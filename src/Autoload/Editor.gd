# Manage editor interaction
extends Node

signal scene_cleared

enum Type { root, dialogue, choice, condition, signal_node }
enum Notification { idle, warning, error, success }

var workspace := {}
var workspace_pristine := true
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
	Events.connect("save_file_button_pressed", self, "save_file")
	Events.connect("new_file_button_pressed", self, "new_file")
	Events.connect("quit_workspace_button_pressed", self, "load_welcome_screen")
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
	if FileManager.state == FileManager.State.unregistred_dirty:
		Serialize.save()
		print_debug(
			"%s has been cached inside %s" % [FileManager.edited_file.path, Serialize.current_path]
		)
	else:
		# Cache prevous file
		FileManager.cache_file()

	reset()
	load_last_opened_file = false
	yield(get_tree(), "idle_frame")

	# force new root on creation
	var root_instance = root_node.instance()
	root_instance.uuid = "root"
	root_instance.name = "root"
	graph_edit.add_child(root_instance)

	Events.emit_signal("workspace_unsaved_file_added")
	FileManager.state = FileManager.State.unregistred_pristine


func open_file() -> void:
	FileManager.state = FileManager.State.registred_pristine
	Events.emit_signal("file_dialog_opened", 0)  # FileDialog.Mode.MODE_OPEN_FILE


func load_welcome_screen() -> void:
	reset()

	workspace_pristine = true
	graph_edit = null
	load_last_opened_file = true

	get_tree().change_scene("res://src/WelcomePage/WelcomePage.tscn")
	FileManager.clear()
	yield(FileManager, "cache_cleared")


func absolute_path(path: String) -> String:
	return path.replace(Constant.RESOURCE, workspace.resource).replace("//", "/")


func resource_path(path: String) -> String:
	print(workspace.resource)
	print(path.replace(workspace.resource, Constant.RESOURCE))
	return path.replace(workspace.resource, Constant.RESOURCE)


func import_image(path: String, size: Vector2) -> ImageTexture:
	var texture := ImageTexture.new()
	var image := Image.new()

	var err = image.load(absolute_path(path))
	assert(err == OK)

	texture.create_from_image(image, 0)
	texture.set_size_override(size)

	return texture


func new_root_node() -> void:
	if graph_edit.get_node_or_null("root") != null:
		return

	var root_instance = root_node.instance()
	root_instance.uuid = "root"
	root_instance.name = "root"
	graph_edit.add_child(root_instance)
