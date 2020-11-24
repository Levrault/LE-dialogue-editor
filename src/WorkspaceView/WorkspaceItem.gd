extends HBoxContainer

onready var button := $Button

func _ready() -> void:
	button.connect("values_changed", $WorkspaceItemMenuButton, "_on_Values_changed")
