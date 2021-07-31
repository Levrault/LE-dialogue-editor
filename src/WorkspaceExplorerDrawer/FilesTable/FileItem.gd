# Created by FilesTable.gd  
# Make the connection between FileActionsButton and FileItemContextualMenu

extends HBoxContainer

onready var button := $FileActionsButton


func _ready() -> void:
	button.connect("values_changed", $FileItemContextualMenu, "_on_Values_changed")
