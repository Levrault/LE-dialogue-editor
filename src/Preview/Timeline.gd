extends VBoxContainer

var preview_dialogue_left = preload("res://src/Preview/PreviewDialogueLeft.tscn")
var preview_dialogue_right = preload("res://src/Preview/PreviewDialogueRight.tscn")
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

	if dialogue.has("name") and not dialogue.name.empty():
		_push_speaker(dialogue.name)

	if dialogue.has("next"):
		_create_timeline(Store.json_raw[dialogue.next].duplicate(), form_conditions, dialogue.next)
		return

	var next := ""
	if dialogue.has("conditions"):
		var conditions = dialogue.conditions.duplicate(true)
		for condition in conditions:
			var next_dialogue = condition.next
			condition.erase("next")
			var is_root_matched := true

			# empty condition
			if condition.empty() and form_conditions.empty():
				_create_timeline(
					Store.json_raw[next_dialogue].duplicate(), form_conditions, next_dialogue
				)
				return

			for key in condition:
				if not form_conditions.has(key):
					is_root_matched = false
					continue
				if not is_root_matched:
					continue
				next = next_dialogue
			if is_root_matched and not next.empty():
				break
				
		if next.empty():
			# TODO: display invalid route message error
			return

		_create_timeline(Store.json_raw[next].duplicate(), form_conditions, next)


func _push_speaker(name: String) -> void:
	if should_add_speaker_to_left and not speakers.left.has(name):
		speakers.left[name] = true
		should_add_speaker_to_left = false
		return

	if not speakers.right.has(name):
		speakers.right[name] = true
