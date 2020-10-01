extends Button


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")


func _on_Pressed() -> void:
	Events.emit_signal("graph_node_added", Editor.choice_node.instance())
	Events.emit_signal("preview_button_activated")
