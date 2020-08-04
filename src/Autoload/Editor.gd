extends Node

enum Type { start, dialogue, choice, condition }

var locale := 'en' setget set_locale


func set_locale(value: String) -> void:
	locale = value
	Events.emit_signal("locale_changed", value)
