extends Node

var Parser = load("res://src/Utils/Parser.gd")
var json_raw := {}
var choices_node := {}
var conditions_node := {}
var signals_node := {}
var dialogues_node := {}
var dialogues_uuid := []

onready var parser = Parser.new()


func _ready() -> void:
	Events.connect("dialogue_node_created", self, "_on_Dialogue_node_created")
	Events.connect("choice_node_created", self, "_on_Choice_node_created")
	Events.connect("condition_node_created", self, "_on_Condition_node_created")
	Events.connect("signal_node_created", self, "_on_Signal_node_created")

	# start to dialogue
	Events.connect(
		"start_to_dialogue_relation_changed", self, "_on_Start_to_dialogue_relation_changed"
	)

	# Dialogue to dialogue
	Events.connect(
		"dialogue_to_dialogue_relation_created", self, "_on_Dialogue_to_dialogue_relation_created"
	)
	Events.connect(
		"dialogue_to_dialogue_relation_deleted", self, "_on_Dialogue_to_dialogue_relation_deleted"
	)

	# dialogue to conditions
	Events.connect(
		"dialogue_to_condition_relation_created", self, "_on_Dialogue_to_condition_relation_created"
	)

	# Dialogue to signal
	Events.connect(
		"dialogue_to_signal_relation_created", self, "_on_Dialogue_to_signal_relation_created"
	)
	Events.connect(
		"dialogue_to_signal_relation_deleted", self, "_on_Dialogue_to_signal_relation_deleted"
	)

	# Dialogue to choice
	Events.connect(
		"dialogue_to_choice_relation_created", self, "_on_Dialogue_to_choice_relation_created"
	)
	Events.connect(
		"dialogue_to_choice_relation_deleted", self, "_on_Dialogue_to_choice_relation_deleted"
	)

	# Choice to dialogue
	Events.connect(
		"choice_to_dialogue_relation_created", self, "_on_Choice_to_dialogue_relation_created"
	)
	Events.connect(
		"choice_to_dialogue_relation_deleted", self, "_on_Choice_to_dialogue_relation_deleted"
	)


func to_json() -> String:
	return parser.to_json(json_raw)


func _on_Dialogue_node_created(data: Dictionary) -> void:
	if json_raw.empty():
		data.values["root"] = true

	json_raw[data.uuid] = data.values.data
	dialogues_node[data.uuid] = data.values
	dialogues_uuid.append(data.uuid)


func _on_Choice_node_created(data: Dictionary) -> void:
	choices_node[data.uuid] = data.values


func _on_Condition_node_created(data: Dictionary) -> void:
	conditions_node[data.uuid] = data.values


func _on_Signal_node_created(data: Dictionary) -> void:
	signals_node[data.uuid] = data.values


func _on_Start_to_dialogue_relation_changed(from: String) -> void:
	# remove previous first
	for uuid in dialogues_uuid:
		if json_raw[uuid].has("root"):
			json_raw[uuid].erase("root")

	# new one 
	dialogues_uuid.push_front(from)
	json_raw[from]["root"] = true

	# re-order structure : Lazy way, destroy and rebuild
	var previous_json_raw := json_raw.duplicate()
	json_raw = {}
	for uuid in dialogues_uuid:
		json_raw[uuid] = previous_json_raw[uuid]


func _on_Dialogue_to_dialogue_relation_created(from: String, to: String) -> void:
	json_raw[from]["next"] = to


func _on_Dialogue_to_dialogue_relation_deleted(from: String) -> void:
	json_raw[from].erase("next")


func _on_Dialogue_to_condition_relation_created(from: String, to: String) -> void:
	if not json_raw[from].has("conditions"):
		json_raw[from]["conditions"] = []
	json_raw[from].conditions = conditions_node[to].data


func _on_Dialogue_to_choice_relation_created(from: String, to: String) -> void:
	if not json_raw[from].has("choices"):
		json_raw[from]["choices"] = []
	json_raw[from].choices.append(choices_node[to].data)


func _on_Dialogue_to_choice_relation_deleted(from: String, to: String) -> void:
	json_raw[from]["choices"].erase(choices_node[to])


func _on_Dialogue_to_signal_relation_created(from: String, to: String) -> void:
	if not json_raw[from].has("signals"):
		json_raw[from]["signals"] = []
	json_raw[from].signals = signals_node[to].data


func _on_Dialogue_to_signal_relation_deleted(from: String, to: String) -> void:
	json_raw[from]["signals"].erase(signals_node[to])


func _on_Choice_to_dialogue_relation_created(from: String, to: String) -> void:
	choices_node[from].next = to


func _on_Choice_to_dialogue_relation_deleted(from: String) -> void:
	choices_node[from].next = ""
