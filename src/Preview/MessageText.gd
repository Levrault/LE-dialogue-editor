extends PopInPanel

var message := "" setget set_message

onready var rich_text_label := $MarginContainer/RichTextLabel
onready var margin_container := $MarginContainer


func set_message(new_message: String) -> void:
	message = new_message
	rich_text_label.text = new_message
