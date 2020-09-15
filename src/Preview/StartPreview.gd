extends Button


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")
	Events.connect("preview_finished", self, "_on_Preview_finished")


func _on_Pressed() -> void:
	Events.emit_signal("preview_started", owner.conditions)
	disabled = true


func _on_Preview_finished() -> void:
	disabled = false
