# Owner dependant
# Read associated dialogue json file to NPC 
# Based on NPC name
# Order and manage which dialogue is send to DialogueBox
class_name DialogueController
extends Node2D

const PORTRAIT_PATH: String = "res://assets/portraits/%s.png"
const _portraits_res := {}

var _dialogues := {}
var _conditions := {}
var _current_dialogue := {}

onready var dialogue_json: Dictionary = Store.json_raw


# preload all portrait resources into memory
func _ready() -> void:
	print(dialogue_json)


#	for key in dialogue_json:
#		var values: Dictionary = dialogue_json[key]
#		if not values.has("portrait"):
#			continue
#		if _portraits_res.has(values["portrait"]):
#			continue
#		_portraits_res[values["portrait"]] = load(PORTRAIT_PATH % [values["portrait"]])


func start() -> void:
	Events.emit_signal("dialogue_started")
	owner.set_process_unhandled_input(false)
	change()


# Send dialogue based on locale to the dialogueBox
func next() -> void:
	_current_dialogue = _dialogues[_current_dialogue["next"]]
	change()


func change() -> void:
	var text: String = _current_dialogue["text"][TranslationServer.get_locale()]
	Events.emit_signal(
		"dialogue_changed",
		_current_dialogue["name"],
		_portraits_res[_current_dialogue["portrait"]],
		text
	)

	if _current_dialogue.has("signals"):
		_emit_dialogue_signal(_current_dialogue["signals"])

	# player can make some choice
	if _current_dialogue.has("choices"):
		Events.emit_signal("dialogue_choices_changed", _current_dialogue["choices"])
		Events.connect("dialogue_choices_finished", self, "_on_Choices_finished")
		return

	# timed dialogue
	if _current_dialogue.has("timer"):
		Events.emit_signal("dialogue_timed", _current_dialogue["timer"])

	# there is not linked dialogue 
	if not _current_dialogue.get("next"):
		Events.emit_signal("dialogue_last_dialogue_displayed")
		clear()


# Load dialogue
func load() -> void:
	_conditions = owner.conditions if owner.get("conditions") else {}
	_get_conditional_dialogue()


# clear controller
func clear() -> void:
	_dialogues = {}
	_current_dialogue = {}
	_conditions = {}


# If the owner didn't have any condition set
func _get_non_conditional_dialogue():
	var is_first_dialogue := false
	for key in dialogue_json:
		var values: Dictionary = dialogue_json[key]
		if values.has("conditions"):
			continue

		if not is_first_dialogue:
			_current_dialogue = values
			is_first_dialogue = true

		_dialogues[key] = values


# Get the first matching dialogue. Everything must match
# e.g. 
# 	If the owner has a condition has_been_talked_to
#	Dialogue with condition {has_been_talked_to: true, other_condition: true} will NOT match;
# 	Only the dialogue with the same condition will work
# e.g. bis
# 	If the owner has a condition has_been_talked_to and other_condition
#	Dialogue with condition only the condition {has_been_talked_to: true} will NOT match;
# 	Only the dialogue with the same condition will work
func _get_conditional_dialogue():
	# _get_non_conditional_dialogue()
	var root: Dictionary = dialogue_json.root
	print(root)
	var is_first_dialogue := false
	for dialogue_key in dialogue_json:
		var values: Dictionary = dialogue_json[dialogue_key]
		if not values.has("conditions"):
			continue

		var dialogue_conditions: Array = values["conditions"]
		var is_dialogue_matched := false
		for condition in _conditions:
			for condition_key in condition:
				if not dialogue_conditions.has(condition_key):
					continue

				is_dialogue_matched = (
					dialogue_conditions[condition_key]
					== _conditions[condition_key]
				)

				if not is_dialogue_matched:
					print_debug("%s has not meet the condition" % [dialogue_key])
					break

			if not is_dialogue_matched:
				continue

			if not is_first_dialogue:
				_current_dialogue = values
				is_first_dialogue = true

		_dialogues[dialogue_key] = values


func _convert_value_to_type(type: String, value):
	match type:
		"Vector2":
			return Vector2(value["x"], value["y"])

	return value


func _on_Choices_finished(key: String) -> void:
	Events.disconnect("dialogue_choices_finished", self, "_on_Choices_finished")
	_current_dialogue = _dialogues[key]
	change()


# Emit signal at current dialogue
# @param {Dictionary} signals
func _emit_dialogue_signal(signals: Dictionary) -> void:
	for key in signals:
		if not signals[key] is Dictionary:
			if signals[key] == null:
				Events.emit_signal(key)
				continue
			Events.emit_signal(key, signals[key])
			continue

		var multi_values_signal: Dictionary = signals[key]
		for type in multi_values_signal:
			var value = _convert_value_to_type(type, multi_values_signal[type])
			Events.emit_signal(key, value)
