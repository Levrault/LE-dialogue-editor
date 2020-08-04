extends Button


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")


func _on_Pressed() -> void:
	if Editor.locale == text:
		return
	Editor.locale = text
