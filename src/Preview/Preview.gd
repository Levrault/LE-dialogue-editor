extends Control


onready var timeline_container := $MarginContainer/Container/TimelineContainer

func _ready() -> void:
	Events.connect("layout_preview_toggled", self, "_on_Layout_preview_toggled")
	Events.connect("preview_started", self, "_on_Preview_started")


func _on_Layout_preview_toggled() -> void:
	visible = not visible


func _on_Preview_started(form_conditions: Dictionary) -> void:
	timeline_container.show()
