extends Node

enum Type { start, dialogue, choice, condition, signal_node }
enum FileState { new, opened, unsaved, saved }

var current_state = FileState.new
var locale := 'en' setget set_locale

onready var dialogue_node := load("res://src/Nodes/Dialogue/DialogueNode.tscn")
onready var choice_node := load("res://src/Nodes/Choice/ChoiceNode.tscn")
onready var condition_node := load("res://src/Nodes/Conditions/ConditionNode.tscn")
onready var signal_node := load("res://src/Nodes/Signal/SignalNode.tscn")


func type_to_string(value: int) -> String:
	var result := ''
	match value:
		Type.start:
			result = 'start'
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


func save_file() -> void:
	if current_state == FileState.new:
		Events.emit_signal("file_dialog_opened", 4)  # FileDialog.Mode.MODE_SAVE_FILE
		return
	if current_state == FileState.saved:
		Serialize.save()
	return


func open_file() -> void:
	if current_state == FileState.unsaved:
		print_debug("file has unsaved change")
		return

	current_state = Editor.FileState.opened
	Events.emit_signal("file_dialog_opened", 0)  # FileDialog.Mode.MODE_OPEN_FILE


func generate_graph(json: Dictionary) -> void:
	print_debug("BEGIN GRAPH GENERATION")
	print(json)
	for uuid in json:
		var dialogue_instance = dialogue_node.instance()
		dialogue_instance.values = json[uuid]
		Events.emit_signal("graph_node_loaded", dialogue_instance)
		if json[uuid].has("conditions"):
			print_debug("conditions")
			print(json[uuid])
			var conditions_instance = condition_node.instance()
			conditions_instance.uuid = Uuid.v4()
			conditions_instance.values = json[uuid].conditions
			dialogue_instance.connected_to_condition = conditions_instance.uuid
			Events.emit_signal("graph_node_loaded", conditions_instance)

		if json[uuid].has("signals"):
			var signals_instance = signal_node.instance()
			signals_instance.uuid = Uuid.v4()
			signals_instance.values = json[uuid].signals
			dialogue_instance.connected_to_signal = signals_instance.uuid
			Events.emit_signal("graph_node_loaded", signals_instance)

		if json[uuid].has("choices"):
			for choice in json[uuid].choices:
				var choices_instance = choice_node.instance()
				choices_instance.uuid = Uuid.v4()
				choices_instance.values = choice
				Events.emit_signal("graph_node_loaded", choices_instance)
	Events.emit_signal("file_loaded")
	print_debug("END GRAPH GENERATION")
