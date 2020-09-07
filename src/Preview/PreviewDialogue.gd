tool
extends VBoxContainer

export var is_speaker_displayed := true

var value := {} setget set_value

onready var speaker = $Speaker
onready var message_text = $MarginContainer/MessageText


func _process(delta: float) -> void:
	if Engine.editor_hint:
		if speaker.visible != is_speaker_displayed:
			speaker.visible = is_speaker_displayed


func set_value(value: Dictionary) -> void:
	speaker.text = "%s - %s" % [value.speaker, value.portrait]
	message_text.text = value.text[Editor.locale]
