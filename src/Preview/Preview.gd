extends Control


func _ready() -> void:
	Events.connect("layout_preview_toggled", self, "_on_Layout_preview_toggled")


func _on_Layout_preview_toggled() -> void:
	visible = not visible
