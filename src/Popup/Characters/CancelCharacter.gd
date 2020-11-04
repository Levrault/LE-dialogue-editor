# Cancel current editing of a character
extends Button


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")


func _on_Pressed() -> void:
	owner.reset_form()
	hide()
