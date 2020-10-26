extends ToolButton


func _ready():
	connect("pressed", self, "_on_Pressed")

func _on_Pressed() -> void:
	Events.emit_signal("characters_pop_up_displayed")
