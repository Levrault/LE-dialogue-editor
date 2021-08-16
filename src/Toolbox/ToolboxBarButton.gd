extends AnimatedToolButton


func _ready() -> void:
	disconnect("pressed", Events, "emit_signal")
	connect("pressed", self, "_on_Pressed")


func _on_Pressed() -> void:
	Events.emit_signal(signal_on_pressed)
