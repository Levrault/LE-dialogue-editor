extends Control

onready var container := $Container


func _ready() -> void:
	for child in container.get_children():
		child.connect("pressed", self, "_on_Pressed", [child])
		if child.text == Editor.locale:
			child.pressed = true


func _on_Pressed(selected_child: Button) -> void:
	for child in container.get_children():
		child.pressed = false
	selected_child.pressed = true
