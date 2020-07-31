extends ToolButton

var dialog_node := preload("res://src/Node/DialogNode.tscn")


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")


func _on_Pressed() -> void:
	Events.emit_signal("dialog_node_created", dialog_node.instance())
