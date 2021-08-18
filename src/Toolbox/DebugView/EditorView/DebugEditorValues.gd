extends VBoxContainer

onready var workspace := $Workspace
onready var workspace_data := $WorkspaceData
onready var workspace_pristine := $WorkspacePristine
onready var load_last_opened_file := $LoadLastOpenedFile
onready var is_loading := $IsLoading
onready var locale := $Locale/Value


func _ready() -> void:
	workspace.connect("toggled", self, "_on_Toggled", [workspace_data])


func _process(delta) -> void:
	workspace_data.text = JSON.print(Editor.workspace, "\t")
	workspace_pristine.pressed = Editor.workspace_pristine
	load_last_opened_file.pressed = Editor.load_last_opened_file
	is_loading.pressed = Editor.is_loading
	locale.text = Editor.locale


func _on_Toggled(button_pressed: bool, rich_text_label: RichTextLabel) -> void:
	rich_text_label.visible = button_pressed
