extends WindowDialog

const INITIAL_VALUE := {"name": "", "folder": "", "resource": ""}

var form_values := INITIAL_VALUE.duplicate(true)
var folder_valid := false setget set_folder_valid
var resource_valid := false setget set_resource_valid

onready var name_field := $MarginContainer/Content/NameField
onready var folder_path_field = $MarginContainer/Content/FolderPathFieldContainer/FolderPathField
onready var resource_path_field = $MarginContainer/Content/ResourcePathFieldContainer/ResourcePathField
onready var cancel_button := $MarginContainer/Content/MarginContainer/ActionsField/CancelWorkspaceButton
onready var save_button := $MarginContainer/Content/MarginContainer/ActionsField/SaveNewWorkspaceButton


func _ready() -> void:
	Events.connect("new_workspace_dialog_displayed", self, "popup")
	name_field.connect("text_changed", self, "_on_Text_changed")
	cancel_button.connect("pressed", self, "_on_Cancel")
	save_button.connect("pressed", self, "_on_Save")


func set_folder_valid(value: bool) -> void:
	folder_valid = value
	_valid_form()


func set_resource_valid(value: bool) -> void:
	resource_valid = value
	_valid_form()


func _valid_form() -> void:
	if folder_valid and resource_valid and not name_field.text.empty():
		save_button.disabled = false
	else:
		save_button.disabled = true


func _on_Save() -> void:
	var values := {
		"path":
		{
			"name": form_values.name,
			"folder": "%s/%s.cfg" % [form_values.folder, form_values.name],
			"resource": form_values.resource,
		}
	}
	Config.new_workspace(values, values.path.folder)
	Events.emit_signal("recents_list_changed")
	_on_Cancel()


func _on_Cancel() -> void:
	self.folder_valid = false
	self.resource_valid = false
	form_values = INITIAL_VALUE.duplicate(true)
	name_field.text = ""
	folder_path_field.value = ""
	resource_path_field = ""
	hide()


func _on_Text_changed(new_text: String) -> void:
	form_values.name = new_text
	_valid_form()
