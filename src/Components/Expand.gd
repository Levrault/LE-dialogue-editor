extends AnimatedToolButton


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")


func _on_Pressed() -> void:
	Events.emit_signal("expand_text_dialogued_opened", owner)
