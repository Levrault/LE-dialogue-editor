extends Node

var json_raw := {}
var root_node = null
var choices_node := {}
var conditions_node := {}
var signals_node := {}
var dialogues_node := {}
var dialogues_uuid := []


func _ready() -> void:
	Events.connect("dialogue_node_created", self, "_on_Dialogue_node_created")
	Events.connect("choice_node_created", self, "_on_Choice_node_created")
	Events.connect("condition_node_created", self, "_on_Condition_node_created")
	Events.connect("signal_node_created", self, "_on_Signal_node_created")

	# root to dialogue
	Events.connect(
		"root_to_dialogue_relation_created", self, "_on_Root_to_dialogue_relation_created"
	)
	Events.connect(
		"root_to_dialogue_relation_deleted", self, "_on_Root_to_dialogue_relation_deleted"
	)

	# root to condition
	Events.connect(
		"root_to_condition_relation_created", self, "_on_Root_to_condition_relation_created"
	)
	Events.connect(
		"root_to_condition_relation_deleted", self, "_on_Root_to_condition_relation_deleted"
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
	Events.connect(
		"dialogue_to_condition_relation_deleted", self, "_on_Dialogue_to_condition_relation_deleted"
	)

	# condition to dialogue
	Events.connect(
		"condition_to_dialogue_relation_created", self, "_on_Condition_to_dialogue_relation_created"
	)
	Events.connect(
		"condition_to_dialogue_relation_deleted", self, "_on_Condition_to_dialogue_relation_deleted"
	)

	# condition to choice
	Events.connect(
		"condition_to_choice_relation_created", self, "_on_Condition_to_choice_relation_created"
	)
	Events.connect(
		"condition_to_choice_relation_deleted", self, "_on_Condition_to_choice_relation_deleted"
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


func get_connected_nodes(nodes: Dictionary, dialogue_uuid: String) -> Array:
	var result := []
	for key in nodes:
		if nodes[key].data.has("next") and nodes[key].data.next == dialogue_uuid:
			result.append(nodes[key])
	return result


func remove_locale(locale: String) -> void:
	for key in dialogues_node:
		dialogues_node[key].data.text.erase(locale)


# Root
func _on_Root_to_dialogue_relation_created(from: String) -> void:
	if not json_raw.root.has("next"):
		json_raw.root["next"] = ""
	json_raw.root.next = from


func _on_Root_to_dialogue_relation_deleted() -> void:
	json_raw.root.erase("next")


func _on_Root_to_condition_relation_created(to: String) -> void:
	if not json_raw.root.has("conditions"):
		json_raw.root["conditions"] = []
	json_raw.root.conditions.append(conditions_node[to].data)


func _on_Root_to_condition_relation_deleted(to: String) -> void:
	json_raw.root.conditions.erase(conditions_node[to].data)


# Dialogue
func _on_Dialogue_node_created(data: Dictionary) -> void:
	json_raw[data.uuid] = data.values.data
	dialogues_node[data.uuid] = data.values
	dialogues_uuid.append(data.uuid)


func _on_Dialogue_to_dialogue_relation_created(from: String, to: String) -> void:
	json_raw[from]["next"] = to


func _on_Dialogue_to_dialogue_relation_deleted(from: String) -> void:
	json_raw[from].erase("next")


# Condition
func _on_Condition_node_created(data: Dictionary) -> void:
	conditions_node[data.uuid] = data.values


func _on_Dialogue_to_condition_relation_created(from: String, to: String) -> void:
	if not json_raw[from].has("conditions"):
		json_raw[from]["conditions"] = []
	json_raw[from].conditions.append(conditions_node[to].data)

	# if is in "conditional choice" context, remove choice
	if conditions_node[to].__editor.has("choice_uuid"):
		_on_Dialogue_to_choice_relation_created(from, conditions_node[to].__editor.choice_uuid)


func _on_Dialogue_to_condition_relation_deleted(from: String, to: String) -> void:
	json_raw[from]["conditions"].erase(conditions_node[to].data)
	if json_raw[from]["conditions"].empty():
		json_raw[from].erase("conditions")

	# if is in "conditional choice" context, remove choice
	if conditions_node[to].__editor.has("choice_uuid"):
		_on_Dialogue_to_choice_relation_deleted(from, conditions_node[to].__editor.choice_uuid)


func _on_Condition_to_dialogue_relation_created(from: String, to: String) -> void:
	conditions_node[from].data.next = to


func _on_Condition_to_dialogue_relation_deleted(from: String) -> void:
	conditions_node[from].data.next = ""


func _on_Condition_to_choice_relation_created(from: String, to: String) -> void:
	conditions_node[from].data.next = to

	# keep track of conditions/choice relation
	if not conditions_node[from].__editor.has("choice_uuid"):
		conditions_node[from].__editor["choice_uuid"] = ""
	conditions_node[from].__editor.choice_uuid = to

	# keep track in choice too
	if not choices_node[to].__editor.has("condition_uuid"):
		choices_node[to].__editor["condition_uuid"] = ""
	choices_node[to].__editor.condition_uuid = from

	# sync choice to the dialogue node
	var parent = conditions_node[from].__editor.get("parent")
	if parent:
		_on_Dialogue_to_choice_relation_created(parent, to)


func _on_Condition_to_choice_relation_deleted(from: String, to: String) -> void:
	conditions_node[from].data.next = ""
	conditions_node[from].__editor.erase("choice_uuid")

	var parent = conditions_node[from].__editor.get("parent")
	if parent:
		_on_Dialogue_to_choice_relation_deleted(parent, to)


# Signals
func _on_Signal_node_created(data: Dictionary) -> void:
	signals_node[data.uuid] = data.values


func _on_Dialogue_to_signal_relation_created(from: String, to: String) -> void:
	if not json_raw[from].has("signals"):
		json_raw[from]["signals"] = []
	json_raw[from].signals = signals_node[to].data


func _on_Dialogue_to_signal_relation_deleted(from: String) -> void:
	json_raw[from].erase("signals")


# Choices
func _on_Choice_node_created(data: Dictionary) -> void:
	choices_node[data.uuid] = data.values


func _on_Dialogue_to_choice_relation_created(from: String, to: String) -> void:
	if not json_raw[from].has("choices"):
		json_raw[from]["choices"] = []
	json_raw[from].choices.append(choices_node[to].data)


func _on_Dialogue_to_choice_relation_deleted(from: String, to: String) -> void:
	json_raw[from]["choices"].erase(choices_node[to].data)
	if choices_node.empty():
		json_raw[from].erase("choices")


func _on_Choice_to_dialogue_relation_created(from: String, to: String) -> void:
	choices_node[from].data.next = to


func _on_Choice_to_dialogue_relation_deleted(from: String) -> void:
	choices_node[from].data.next = ""
