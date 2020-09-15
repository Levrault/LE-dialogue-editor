tool
extends VBoxContainer

export var is_speaker_displayed := true

var value := {} setget set_value

onready var speaker = $Speaker
onready var speaker_name = $Speaker/Name
onready var portrait = $Speaker/Portrait
onready var message_text = $MarginContainer/MessageText


func _process(delta: float) -> void:
	if Engine.editor_hint:
		if speaker.visible != is_speaker_displayed:
			speaker.visible = is_speaker_displayed


func set_value(value: Dictionary) -> void:
	speaker_name.text = value.name
	portrait.text = value.portrait
	message_text.message = value.text[Editor.locale]
	message_text.call_deferred("pop_in_animation")
