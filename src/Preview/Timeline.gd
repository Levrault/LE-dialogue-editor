# Display a dialogue route based on the condition
# Display the dialogue, signals, choices in a windows
# Hightlight the route in the editor
extends VBoxContainer

enum State { dialogue, signals, choices }

const TRANSITION_DURATION := .1

var dialogue_left_scene = preload("res://src/Preview/PreviewDialogue/PreviewDialogueLeft.tscn")
var dialogue_right_scene = preload("res://src/Preview/PreviewDialogue/PreviewDialogueRight.tscn")
var choice_scene = preload("res://src/Preview/PreviewChoice/PreviewChoice.tscn")
var signal_scene = preload("res://src/Preview/PreviewSignal/PreviewSignal.tscn")

var preview_list := []
var uuid_list := []
var speakers := {"left": {}, "right": {}}
var should_add_speaker_to_left := true

var _form_conditions := {}


func _ready() -> void:
	Events.connect("preview_started", self, "_on_Preview_started")


# Preview predicated route based on selected conditions
# @param {Dictionary} form_conditions
func _on_Preview_started(form_conditions: Dictionary) -> void:
	_form_conditions = form_conditions
	preview_list = []
	uuid_list = []
	for child in get_children():
		child.queue_free()
	_create_timeline(Store.json.root.duplicate(), "root")

	if preview_list.empty():
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"No route can be predicated with the current condition(s)"
		)
		return

	_display_timeline(preview_list)


# Pressing on a choice need to clean the path created after that choice. Last choice is sended
# to take all the data after the "choice" path
# @param {dictionary} 		value
# @param {int} 				index - dialogue index, to resize the list and uuid
# @param {dictionary} 		last_choice - last available choice to clean the list after pressing
# @param {string} 			uuid - current choice uuid
# @param {string} 			parent_uuid - related dialogue uuid
# @param {PreviewChoice} 	this_button - current pressed button
func _on_Choice_pressed(
	value: Dictionary,
	index: int,
	last_choice: Dictionary,
	uuid: String,
	parent_uuid: String,
	this_button: PreviewChoice
) -> void:
	if value.next.empty():
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"The choice isn't related to any dialogue"
		)
		this_button.has_error()
		return

	# clean if preview answer
	if not last_choice.uuid == get_child(get_child_count() - 1).name:
		var slice_start_to := get_children().find(get_node(last_choice.uuid)) + 1
		var children_to_delete := get_children().slice(slice_start_to, get_child_count(), 1)
		# does those value are one of our current choice
		for child in children_to_delete:
			child.queue_free()

	# clean preview list
	preview_list.resize(index)

	# clean uuid list
	uuid_list.resize(uuid_list.find(parent_uuid) + 1)
	uuid_list.append(uuid)

	# display
	_create_timeline(Store.json[value.next].duplicate(), value.next)
	_display_timeline(preview_list, index)


# Recursive function that get the correct dialogue
# On every iteration, all dictionary are computed to predicate the next dialogue
# @param {Dictionary} 	dialogue
# @param {String} 		uuid - next dialogue, if empty stop function
func _create_timeline(dialogue: Dictionary, uuid := "") -> void:
	if uuid != "root":
		if not uuid.empty():
			preview_list.append({uuid = uuid, dialogue = dialogue})
			uuid_list.append(uuid)

		var dialogue_node := Editor.graph_edit.get_node(uuid)
		if not dialogue_node.left_condition_connection.empty():
			uuid_list.append(dialogue_node.left_condition_connection)

	if dialogue.has("name"):
		_push_speaker(dialogue.name)

	if dialogue.has("next"):
		_create_timeline(Store.json[dialogue.next].duplicate(), dialogue.next)
		return

	var next := ""
	var default_next := ""
	var can_not_predicate := false

	if dialogue.has("conditions") and not dialogue.has("choices"):
		var conditions = dialogue.conditions.duplicate(true)
		var matching_condition := 0

		for condition in conditions:
			var predicated_next: String = condition.next
			condition.erase("next")

			if condition.empty():
				default_next = predicated_next

			# partial matching
			var current_matching_condition := 0
			for key in condition:
				if _form_conditions.has(key):
					# conditions will never match
					if _form_conditions.size() < condition.size():
						continue

					if condition.empty():
						default_next = predicated_next

					if _is_operator_matching(
						condition[key].operator, _form_conditions[key], condition[key].value
					):
						current_matching_condition += 1

			if current_matching_condition > matching_condition:
				matching_condition = current_matching_condition
				next = predicated_next

		# take default empty branch if nothing has match
		if next.empty():
			if default_next.empty():
				Events.emit_signal(
					"notification_displayed",
					Editor.Notification.error,
					"No route can be predicated with the current condition(s)"
				)
				return
			_create_timeline(Store.json[default_next].duplicate(), default_next)
			return

		# take best matching branch
		_create_timeline(Store.json[next].duplicate(), next)


# Add speaker line to dialogue
# @param {String} name
func _push_speaker(name: String) -> void:
	if should_add_speaker_to_left and not speakers.left.has(name):
		speakers.left[name] = true
		should_add_speaker_to_left = false
		return

	if not speakers.right.has(name):
		speakers.right[name] = true


# Add scene based on the start_at index. Start index
# is use to re-render when a choice is made only at the choice position
# @param {Array} 	list
# @param {int} 		(start_at=0)
func _display_timeline(list: Array, start_at: int = 0) -> void:
	var index := start_at
	var items := list.slice(start_at, list.size(), 1, true)

	for item in items:
		var timer := get_tree().create_timer(TRANSITION_DURATION)
		yield(timer, "timeout")

		# dialogue
		var preview_dialogue = null
		if speakers.left.has(item.dialogue.name):
			preview_dialogue = dialogue_left_scene.instance()
		elif speakers.right.has(item.dialogue.name):
			preview_dialogue = dialogue_right_scene.instance()

		add_child(preview_dialogue)
		preview_dialogue.value = item.dialogue
		preview_dialogue.name = item.uuid

		var signals = item.dialogue.get("signals")
		if signals:
			var preview_signal = signal_scene.instance()
			add_child(preview_signal)
			preview_signal.name = Editor.graph_edit.get_node(item.uuid).right_signal_connection
			preview_signal.values = signals
			uuid_list.append(preview_signal.name)

		# choices
		if item.dialogue.has("choices"):
			var choices = _filter_choice(item.uuid)

			for i in range(0, choices.size()):
				var timer_choice := get_tree().create_timer(TRANSITION_DURATION)
				yield(timer_choice, "timeout")

				var preview_choice = choice_scene.instance()
				add_child(preview_choice)

				preview_choice.value = choices[i]
				preview_choice.name = choices[i].uuid

				# add uuid
				preview_choice.button.connect(
					"pressed",
					self,
					"_on_Choice_pressed",
					[
						choices[i],
						items.size(),
						choices[choices.size() - 1],
						preview_choice.name,
						item.uuid,
						preview_choice
					]
				)

	Events.emit_signal("preview_predicated_route_displayed", uuid_list)
	Events.emit_signal("preview_finished")


# does the correct operation based on the operator,
# only does the operation on number type
# @param {String} 	condition_operator - different, greater, lower, equal
# @param {int} 		form_value
# @param {int} 		condition_value
# @returns {bool}
func _is_operator_matching(condition_operator: String, form_value: int, condition_value: int) -> bool:
	var operator: int = Operator.get_operator_enum(condition_operator)

	if operator == Operator.Type.different:
		if form_value != condition_value:
			return true

	if operator == Operator.Type.greater:
		if form_value > condition_value:
			return true

	if operator == Operator.Type.lower:
		if form_value < condition_value:
			return true

	if operator == Operator.Type.equal:
		if form_value == condition_value:
			return true

	return false


# Tricky way to get all the choice and filter them to get the one that match _form_condition value
# @param {string} uuid - dialogue uuid, use to get the node
# @returns {array}
func _filter_choice(uuid: String) -> Array:
	var result := []

	# get non conditional choice
	var choice_uuids: Array = Editor.graph_edit.get_node(uuid).right_choices_connection.duplicate(
		true
	)

	for uuid in choice_uuids:
		var choice_to_add = Editor.graph_edit.get_node(uuid).values.data.duplicate(true)
		choice_to_add["uuid"] = uuid
		result.append(choice_to_add)

	# filter choice by condition
	for condition_uuid in Editor.graph_edit.get_node(uuid).right_conditions_connection:
		var condition_node = Editor.graph_edit.get_node(condition_uuid)
		var condition_data = condition_node.values.data.duplicate(true)
		condition_data.erase("next")

		# conditions will never match
		if _form_conditions.size() < condition_data.size():
			continue

		for key in condition_data:
			if not condition_data.has(key):
				continue
			if not _form_conditions.has(key):
				continue
			if _is_operator_matching(
				condition_data[key].operator, _form_conditions[key], condition_data[key].value
			):
				var choice_to_add = Editor.graph_edit.get_node(condition_node.right_choice_connection).values.data.duplicate(
					true
				)
				choice_to_add["uuid"] = condition_node.right_choice_connection
				result.append(choice_to_add)

	return result
