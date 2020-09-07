extends Button

var text := "" setget set_text
onready var rich_text_label := $MarginContainer/RichTextLabel


func set_text(new_text: String) -> void:
	text = new_text
	rich_text_label.text = text
