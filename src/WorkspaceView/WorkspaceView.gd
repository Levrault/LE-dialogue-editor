extends Control

onready var close_workspace_view := $MarginContainer/Wrapper/HBoxContainer/CloseWorkspaceView
onready var label := $MarginContainer/Wrapper/HBoxContainer/Label


func _ready() -> void:
	Events.connect("layout_workspace_view_toggled", self, "_on_layout_workspace_view_toggled")
	Events.connect("layout_workspace_view_closed", self, "_on_layout_workspace_view_toggled")
	close_workspace_view.connect("pressed", Events, "emit_signal", ["layout_workspace_view_closed"])
	visible = Config.globals.views.workspace
	label.text = Editor.workspace.name


func _on_layout_workspace_view_toggled() -> void:
	visible = not visible
	Config.globals.views.workspace = visible
	Config.save(Config.globals)
