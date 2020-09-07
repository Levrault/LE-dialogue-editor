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

	# read start_node for conditions
	# var root = Store.json_raw.root.duplicate()
	# var next = ''
	# if root.has("conditions"):
	# 	for root_condition in root.conditions:
	# 		var next_dialogue = root_condition.next
	# 		root_condition.erase("next")
	# 		var is_root_matched := true
	# 		for key in root_condition:
	# 			if not form_conditions.has(key):
	# 				is_root_matched = false
	# 				continue
	# 			if not is_root_matched:
	# 				continue
	# 			next = next_dialogue
	# 		if is_root_matched and not next.empty():
	# 			break
	# print(next)

	_create_timeline(Store.json_raw.root.duplicate(), form_conditions)

	for item in timeline:
		var preview_dialogue_instance = null
		if speakers.left.has(item.name):
			preview_dialogue_instance = preview_dialogue_left.instance()
		elif speakers.right.has(item.name):
			preview_dialogue_instance = preview_dialogue_right.instance()

		preview_dialogue_instance.value = item
		add_child(item)


func _create_timeline(dialogue: Dictionary, form_conditions: Dictionary) -> void:
	if not dialogue.speaker.empty():
		_push_speaker(dialogue.speaker)

	if dialogue.has("next"):
		timeline.append(dialogue)
		_create_timeline(Store.json_raw[dialogue.next].duplicate(), form_conditions)
		return

	var next := ""
	if dialogue.has("conditions"):
		for condition in dialogue.conditions:
			var next_dialogue = condition.next
			var is_root_matched := true
			for key in condition:
				if not form_conditions.has(key):
					is_root_matched = false
					continue
				if not is_root_matched:
					continue
				next = next_dialogue
			if is_root_matched and not next.empty():
				break

		_create_timeline(Store.json_raw[next].duplicate(), form_conditions)


func _push_speaker(name: String) -> void:
	if should_add_speaker_to_left and not speakers.left.has(name):
		speakers.left[name] = true
		should_add_speaker_to_left = false
		return

	if not speakers.right.has(name):
		speakers.right[name] = true
