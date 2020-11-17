# Main container
# Create node and send 
extends Control

onready var graph_edit := $MarginContainer/VBoxContainer/HBoxContainer/Editor/GraphEditor


func _ready() -> void:
	Events.connect("menu_popup_displayed", self, "_on_Menu_popup_displayed")
	Events.connect("graph_edit_reloaded_started", self, "_on_Graph_edit_reloaded")
	Editor.graph_edit = graph_edit

	if not Config.values.cache.last_opened_file.empty():
		Serialize.call_deferred("load", Config.values.cache.last_opened_file)


func _on_Menu_popup_displayed(name: String) -> void:
	assert(has_node(name))
	get_node(name).popup()
