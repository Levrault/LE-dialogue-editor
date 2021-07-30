extends Control

onready var close_workspace_explorer_drawer := $MarginContainer/Wrapper/HBoxContainer/CloseWorkspaceView
onready var label := $MarginContainer/Wrapper/HBoxContainer/Label


func _ready() -> void:
	Events.connect("layout_workspace_explorer_drawer_toggled", self, "_on_layout_workspace_explorer_drawer_toggled")
	Events.connect("layout_workspace_explorer_drawer_closed", self, "_on_layout_workspace_explorer_drawer_toggled")
	close_workspace_explorer_drawer.connect("pressed", Events, "emit_signal", ["layout_workspace_explorer_drawer_closed"])
	visible = Config.globals.views.workspace
	label.text = Editor.workspace.name


func _on_layout_workspace_explorer_drawer_toggled() -> void:
	visible = not visible
	Config.globals.views.workspace = visible
	Config.save(Config.globals)
