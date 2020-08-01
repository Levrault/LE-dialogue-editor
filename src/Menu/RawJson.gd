extends ToolButton


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")


func _on_Pressed() -> void:
	Events.emit_signal("menu_popup_displayed", "RawJsonWindows")
