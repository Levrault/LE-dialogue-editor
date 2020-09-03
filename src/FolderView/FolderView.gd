extends Control


func _ready() -> void:
	Events.connect("layout_folder_view_toggled", self, "_on_Layout_folder_view_toggled")


func _on_Layout_folder_view_toggled() -> void:
	visible = not visible
