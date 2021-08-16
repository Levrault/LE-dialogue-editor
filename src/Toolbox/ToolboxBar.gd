extends Control

onready var buttons_container := $MarginContainer/VBoxContainer


func _ready():
	if not Config.values.configuration.has_name and not Config.values.configuration.has_portrait:
		$MarginContainer/VBoxContainer/CharactersButton.queue_free()
