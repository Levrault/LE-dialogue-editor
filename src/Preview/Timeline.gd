extends VBoxContainer

var preview_dialogue_left = preload("res://src/Preview/PreviewDialogueLeft.tscn")
var preview_dialogue_right = preload("res://src/Preview/PreviewDialogueRight.tscn")
var no_route = preload("res://src/Preview/PreviewNoRoute.tscn")
var timeline := []
var speakers := {"left": {}, "right": {}}
var should_add_speaker_to_left := true


func _ready() -> void:
	Events.connect("preview_started", self, "_on_Preview_started")


func _on_Preview_started(form_conditions: Dictionary) -> void:
	timeline = []
	for child in get_children():
		child.queue_free()
	_create_timeline(Store.json_raw.root.duplicate(), form_conditions, "root")

	if timeline.empty():
		add_child(no_route.instance())
		print("in")
		return

	for item in timeline:
		var preview_dialogue_instance = null
		if speakers.left.has(item.name):
			preview_dialogue_instance = preview_dialogue_left.instance()
		elif speakers.right.has(item.name):
			preview_dialogue_instance = preview_dialogue_right.instance()

		var timer := get_tree().create_timer(.15)
		yield(timer, "timeout")
		add_child(preview_dialogue_instance)
		preview_dialogue_instance.value = item


# Recursive function that get the correct dialogue
func _create_timeline(dialogue: Dictionary, form_conditions: Dictionary, uuid: String) -> void:
	if uuid != "root":
		timeline.append(dialogue)

	if dialogue.has("name"):
		_push_speaker(dialogue.name)

	if dialogue.has("next"):
		_create_timeline(Store.json_raw[dialogue.next].duplicate(), form_conditions, dialogue.next)
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
			if form_conditions.size() < condition.size():
				continue

			if condition.empty():
				default_next = predicated_next

			# perfect matching keys
			if condition.has_all(form_conditions.keys()):
				_create_timeline(
					Store.json_raw[predicated_next].duplicate(), form_conditions, predicated_next
				)
				return

			# partial matching
			var current_matching_condition := 0
			for key in condition:
				if form_conditions.has(key):
					current_matching_condition += 1
			if current_matching_condition > matching_condition:
				matching_condition = current_matching_condition
				next = predicated_next

		# take default empty branch if nothing has match
		if next.empty():
			_create_timeline(
				Store.json_raw[default_next].duplicate(), form_conditions, default_next
			)
			return

		# take best matching branch
		_create_timeline(Store.json_raw[next].duplicate(), form_conditions, next)


func _push_speaker(name: String) -> void:
	if should_add_speaker_to_left and not speakers.left.has(name):
		speakers.left[name] = true
		should_add_speaker_to_left = false
		return

	if not speakers.right.has(name):
		speakers.right[name] = true
