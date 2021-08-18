extends MarginContainer

onready var workspaces := $Data/Workspaces
onready var workspaces_data := $Data/WorkspacesData
onready var views := $Data/Views
onready var views_data := $Data/ViewsData
onready var info := $Data/Info
onready var info_data := $Data/InfoData


func _ready() -> void:
	workspaces.connect("toggled", self, "_on_Toggled", [workspaces_data])
	views.connect("toggled", self, "_on_Toggled", [views_data])
	info.connect("toggled", self, "_on_Toggled", [info_data])


func _process(delta) -> void:
	workspaces_data.text = JSON.print(Config.values.path, "\t")
	views_data.text = JSON.print(Config.values.configuration, "\t")
	info_data.text = JSON.print(Config.values.locale, "\t")


func _on_Toggled(button_pressed: bool, rich_text_label: RichTextLabel) -> void:
	rich_text_label.visible = button_pressed
