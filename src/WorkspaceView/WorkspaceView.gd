extends Control


func _ready() -> void:
	Events.connect("layout_workspace_view_toggled", self, "_on_layout_workspace_view_toggled")


func _on_layout_workspace_view_toggled() -> void:
	visible = not visible
