extends VBoxContainer

enum State { dialogue, signals, choices }

const TRANSITION_DURATION := .1

var preview_dialogue_left_scene = preload("res://src/Preview/PreviewDialogueLeft.tscn")
var preview_dialogue_right_scene = preload("res://src/Preview/PreviewDialogueRight.tscn")
var preview_no_route_scene = preload("res://src/Preview/PreviewNoRoute.tscn")
var preview_choice_scene = preload("res://src/Preview/PreviewChoice.tscn")
var preview_signal_scene = preload("res://src/Preview/PreviewSignal.tscn")
var preview_list := []
var uuid_list := []
var speakers := {"left": {}, "right": {}}
var should_add_speaker_to_left := true

var _form_conditions := {}


func _ready() -> void:
	Events.connect("preview_started", self, "_on_Preview_started")


# PreviewDialogue must have uuid has name
func _on_Preview_started(form_conditions: Dictionary) -> void:
	_form_conditions = form_conditions
	preview_list = []
	uuid_list = []
	for child in get_children():
		child.queue_free()
	_create_timeline(Store.json_raw.root.duplicate(), "root")

	if preview_list.empty():
		add_child(preview_no_route_scene.instance())
		return

	_display_timeline(preview_list)


func _on_Choice_pressed(
	value: Dictionary, index: int, choices_size: int, uuid: String, parent_uuid: String
) -> void:
	# clean if preview answer
	print(index + choices_size)
	print(get_children())
	var children_to_delete := get_children().slice(index + choices_size, get_child_count(), 1)
	print(children_to_delete)
	for child in children_to_delete:
		child.queue_free()

	# clean preview list 
	preview_list.resize(index)

	# clean uuid list
	uuid_list.resize(uuid_list.find(parent_uuid) + 1)
	uuid_list.append(uuid)

	# display
	_create_timeline(Store.json_raw[value.next].duplicate(), value.next)
	_display_timeline(preview_list, index)


# Recursive function that get the correct dialogue
func _create_timeline(dialogue: Dictionary, uuid := "") -> void:
	if uuid != "root" and not uuid.empty():
		preview_list.append({uuid = uuid, dialogue = dialogue})
		uuid_list.append(uuid)

	if dialogue.has("name"):
		_push_speaker(dialogue.name)

	if dialogue.has("next"):
		_create_timeline(Store.json_raw[dialogue.next].duplicate(), dialogue.next)
		return

	var next := ""
	var default_next := ""
	var can_not_predicate := false
	if dialogue.has("conditions"):
		var conditions = dialogue.conditions.duplicate(true)
		var matching_condition := 0
		for condition in conditions:
			var predicated_next: String = condition.next
			condition.erase("next")

			# conditions will never match
			if _form_conditions.size() < condition.size():
				continue

			if condition.empty():
				default_next = predicated_next

			# perfect matching keys
			if condition.has_all(_form_conditions.keys()):
				_create_timeline(Store.json_raw[predicated_next].duplicate(), predicated_next)
				return

			# partial matching
			var current_matching_condition := 0
			for key in condition:
				if _form_conditions.has(key):
					current_matching_condition += 1
			if current_matching_condition > matching_condition:
				matching_condition = current_matching_condition
				next = predicated_next

		# take default empty branch if nothing has match
		if next.empty():
			_create_timeline(Store.json_raw[default_next].duplicate(), default_next)
			return

		# take best matching branch
		_create_timeline(Store.json_raw[next].duplicate(), next)


func _push_speaker(name: String) -> void:
	if should_add_speaker_to_left and not speakers.left.has(name):
		speakers.left[name] = true
		should_add_speaker_to_left = false
		return

	if not speakers.right.has(name):
		speakers.right[name] = true


# Add scene based on the start_at index
func _display_timeline(list: Array, start_at: int = 0) -> void:
	var index := start_at
	var items := list.slice(start_at, list.size(), 1, true)

	for item in items:
		var timer := get_tree().create_timer(TRANSITION_DURATION)
		yield(timer, "timeout")

		# dialogue
		var preview_dialogue = null
		if speakers.left.has(item.dialogue.name):
			preview_dialogue = preview_dialogue_left_scene.instance()
		elif speakers.right.has(item.dialogue.name):
			preview_dialogue = preview_dialogue_right_scene.instance()

		add_child(preview_dialogue)
		preview_dialogue.value = item.dialogue
		preview_dialogue.name = item.uuid

		var signals = item.dialogue.get("signals")
		if signals:
			var preview_signal = preview_signal_scene.instance()
			add_child(preview_signal)
			preview_signal.name = Editor.graph_edit.get_node(item.uuid).connected_to_signal
			preview_signal.values = signals
			uuid_list.append(preview_signal.name)

		# choices
		var choices = item.dialogue.get("choices")
		if choices:
			for i in range(0, choices.size()):
				var timer_choice := get_tree().create_timer(TRANSITION_DURATION)
				yield(timer_choice, "timeout")

				var preview_choice = preview_choice_scene.instance()
				add_child(preview_choice)

				preview_choice.value = choices[i]
				preview_choice.name = Editor.graph_edit.get_node(item.uuid).connected_to_choices[i]
				preview_choice.button.connect(
					"pressed",
					self,
					"_on_Choice_pressed",
					[choices[i], items.size(), choices.size(), preview_choice.name, item.uuid]
				)

	Events.emit_signal("preview_predicated_route_displayed", uuid_list)
