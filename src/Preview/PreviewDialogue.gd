tool
extends VBoxContainer

export var is_speaker_displayed := true

onready var speaker = $Speaker


func _ready():
	pass  # Replace with function body.


func _process(delta: float) -> void:
	if Engine.editor_hint:
		if speaker.visible != is_speaker_displayed:
			speaker.visible = is_speaker_displayed
