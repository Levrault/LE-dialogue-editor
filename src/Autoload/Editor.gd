extends Node

enum Type { start, dialogue, choice, condition, signal_node }

var locale := 'en' setget set_locale


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
