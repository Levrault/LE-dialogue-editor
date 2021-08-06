extends Control

const INITIAL_VALUE := {"name": "", "folder": "", "resource": ""}

var form_values := INITIAL_VALUE.duplicate(true)
var folder_valid := false setget set_folder_valid
var resource_valid := false setget set_resource_valid

# field
onready var folder_path_field = $MarginContainer/Content/CenterContainer/Form/FolderPathFieldContainer/FolderPathField
onready var resource_path_field = $MarginContainer/Content/CenterContainer/Form/ResourcePathFieldContainer/ResourcePathField

# buttons
onready var go_back_button := $MarginContainer/Content/Navigation/GoBackButton
onready var save_button := $MarginContainer/Content/CenterContainer/Form/MarginContainer/ActionsField/Import


func _ready() -> void:
	Events.connect("workspace_import_form_displayed", self, "show")

	# button signals
	go_back_button.connect("pressed", self, "_on_Go_back_pressed")
	save_button.connect("pressed", self, "_on_Save")


func set_folder_valid(value: bool) -> void:
	folder_valid = value
	validate()


func set_resource_valid(value: bool) -> void:
	resource_valid = value
	validate()


func validate() -> void:
	if not folder_valid:
		save_button.disabled = true
		return
	if not resource_valid:
		save_button.disabled = true
		return
	save_button.disabled = false


func _on_Save() -> void:
	for workspace in Config.globals.workspaces.list:
		if workspace.folder == form_values.folder:
			Events.emit_signal(
				"notification_displayed",
				Editor.Notification.error,
				"%s already exist in the workspace" % form_values.folder
			)
			_on_Go_back_pressed()
			return

	var file = Config.read_workspace_file(form_values.folder)
	print(form_values)

	Config.globals.workspaces.list.append(
		{
			folder = form_values.folder,
			name = form_values.name,
			OS.get_name(): form_values.resource,
			has_portrait = file.get_value("configuration", "has_portrait", true),
			has_name = file.get_value("configuration", "has_name", true)
		}
	)
	Config.save(Config.globals)
	Events.emit_signal("recents_table_changed")
	_on_Go_back_pressed()


func _on_Go_back_pressed() -> void:
	self.folder_valid = false
	self.resource_valid = false
	form_values = INITIAL_VALUE.duplicate(true)
	folder_path_field.value = ""
	resource_path_field.value = ""
	hide()
