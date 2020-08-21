# Main container
# Create node and send 
extends Control


func _ready() -> void:
	Events.connect("menu_popup_displayed", self, "_on_Menu_popup_displayed")


func _on_Menu_popup_displayed(name: String) -> void:
	assert(has_node(name))
	get_node(name).popup()
