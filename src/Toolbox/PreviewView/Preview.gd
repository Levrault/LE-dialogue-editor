extends Control

onready var timeline_container := $TimelineContainer


func _ready() -> void:
	Events.connect("preview_started", self, "_on_Preview_started")


func _on_Preview_started(form_conditions: Dictionary) -> void:
	timeline_container.show()
