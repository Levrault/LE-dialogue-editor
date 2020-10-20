extends Node

var json := {}
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


# check if a choice, signal, condition is linked to a dialogue
# Since choice next is a dialogue, only the conditions are checks for the following
# case dialogue -> condition -> choice -> dialogue
# @param {String} node_uuid - should be data "parent" saved inside __editor
# @returns {bool}
func has_node_in_json(node_uuid: String) -> bool:
	if node_uuid == "root":
		return true
	for uuid in json:
		var next = json[uuid].get("next")
		if next and next == node_uuid:
			return true

		var conditions = json[uuid].get("conditions")
		if conditions:
			for condition in conditions:
				if not condition.has("next"):
					continue
				if condition.next == node_uuid:
					return true

	return false


func remove_locale(locale: String) -> void:
	for key in dialogues_node:
		dialogues_node[key].data.text.erase(locale)


# Root
func _on_Root_to_dialogue_relation_created(from: String) -> void:
	if not json.root.has("next"):
		json.root["next"] = ""
	json.root.next = from


func _on_Root_to_dialogue_relation_deleted() -> void:
	json.root.erase("next")


func _on_Root_to_condition_relation_created(to: String) -> void:
	if not json.root.has("conditions"):
		json.root["conditions"] = []
	json.root.conditions.append(conditions_node[to].data)


func _on_Root_to_condition_relation_deleted(to: String) -> void:
	json.root.conditions.erase(conditions_node[to].data)


# Dialogue
func _on_Dialogue_node_created(data: Dictionary) -> void:
	json[data.uuid] = data.values.data
	dialogues_node[data.uuid] = data.values
	dialogues_uuid.append(data.uuid)


func _on_Dialogue_to_dialogue_relation_created(from: String, to: String) -> void:
	json[from]["next"] = to


func _on_Dialogue_to_dialogue_relation_deleted(from: String) -> void:
	json[from].erase("next")


# Condition
func _on_Condition_node_created(data: Dictionary) -> void:
	conditions_node[data.uuid] = data.values


func _on_Dialogue_to_condition_relation_created(from: String, to: String) -> void:
	if not json[from].has("conditions"):
		json[from]["conditions"] = []
	json[from].conditions.append(conditions_node[to].data)

	# if is in "conditional choice" context, remove choice
	if conditions_node[to].__editor.has("has_choice"):
		_on_Dialogue_to_choice_relation_created(from, conditions_node[to].data.next)


func _on_Dialogue_to_condition_relation_deleted(from: String, to: String) -> void:
	json[from]["conditions"].erase(conditions_node[to].data)
	if json[from]["conditions"].empty():
		json[from].erase("conditions")

	# if is in "conditional choice" context, remove choice
	if conditions_node[to].__editor.has("has_choice"):
		_on_Dialogue_to_choice_relation_deleted(from, conditions_node[to].data.next)


func _on_Condition_to_dialogue_relation_created(from: String, to: String) -> void:
	conditions_node[from].data.next = to


func _on_Condition_to_dialogue_relation_deleted(from: String) -> void:
	conditions_node[from].data.next = ""


func _on_Condition_to_choice_relation_created(from: String, to: String) -> void:
	conditions_node[from].data.next = to

	# keep track of conditions/choice relation
	if not conditions_node[from].__editor.has("has_choice"):
		conditions_node[from].__editor["has_choice"] = true
	conditions_node[from].__editor.has_choice = true

	# sync choice to the dialogue node
	var parent = conditions_node[from].__editor.get("parent")
	if parent:
		_on_Dialogue_to_choice_relation_created(parent, to)


func _on_Condition_to_choice_relation_deleted(from: String, to: String) -> void:
	conditions_node[from].data.next = ""
	conditions_node[from].__editor.erase("has_choice")

	var parent = conditions_node[from].__editor.get("parent")
	if parent:
		_on_Dialogue_to_choice_relation_deleted(parent, to)


# Signals
func _on_Signal_node_created(data: Dictionary) -> void:
	signals_node[data.uuid] = data.values


func _on_Dialogue_to_signal_relation_created(from: String, to: String) -> void:
	if not json[from].has("signals"):
		json[from]["signals"] = []
	json[from].signals = signals_node[to].data


func _on_Dialogue_to_signal_relation_deleted(from: String) -> void:
	json[from].erase("signals")


# Choices
func _on_Choice_node_created(data: Dictionary) -> void:
	choices_node[data.uuid] = data.values


func _on_Dialogue_to_choice_relation_created(from: String, to: String) -> void:
	if not json[from].has("choices"):
		json[from]["choices"] = []
	json[from].choices.append(choices_node[to].data)


func _on_Dialogue_to_choice_relation_deleted(from: String, to: String) -> void:
	json[from]["choices"].erase(choices_node[to].data)
	if choices_node.empty():
		json[from].erase("choices")


func _on_Choice_to_dialogue_relation_created(from: String, to: String) -> void:
	choices_node[from].data.next = to


func _on_Choice_to_dialogue_relation_deleted(from: String) -> void:
	choices_node[from].data.next = ""
