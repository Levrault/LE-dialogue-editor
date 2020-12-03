extends Control

onready var timeline_container := $MarginContainer/Container/TimelineContainer
onready var close_preview_button := $MarginContainer/Container/HBoxContainer/ClosePreviewButton


func _ready() -> void:
	Events.connect("layout_preview_toggled", self, "_on_Layout_preview_toggled")
	Events.connect("layout_preview_closed", self, "_on_Layout_preview_toggled")
	Events.connect("preview_started", self, "_on_Preview_started")
	close_preview_button.connect("pressed", Events, "emit_signal", ["layout_preview_closed"])
	visible = Config.globals.views.preview


func _on_Layout_preview_toggled() -> void:
	visible = not visible
	Config.globals.views.preview = visible
	Config.save(Config.globals)


func _on_Preview_started(form_conditions: Dictionary) -> void:
	timeline_container.show()
