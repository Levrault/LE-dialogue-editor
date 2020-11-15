extends WindowDialog

const INITIAL_VALUE := {"project_name": "", "project_path": "", "resource_path": ""}

var form_values := INITIAL_VALUE.duplicate(true)
var project_path_valid := false setget set_project_path_valid
var resource_path_valid := false setget set_resource_path_valid

onready var project_name_field := $MarginContainer/Content/ProjectNameField
onready var project_path_field = $MarginContainer/Content/ProjectPathFieldContainer/ProjectPathField
onready var resource_path_field = $MarginContainer/Content/ResourcePathFieldContainer/ResourcePathField
onready var cancel_button := $MarginContainer/Content/MarginContainer/ActionsField/CancelProjectButton
onready var save_button := $MarginContainer/Content/MarginContainer/ActionsField/SaveNewProjectButton


func _ready() -> void:
	Events.connect("new_project_dialog_displayed", self, "popup")
	project_name_field.connect("text_changed", self, "_on_Text_changed")
	cancel_button.connect("pressed", self, "_on_Cancel")
	save_button.connect("pressed", self, "_on_Save")


func set_project_path_valid(value: bool) -> void:
	project_path_valid = value
	_valid_form()


func set_resource_path_valid(value: bool) -> void:
	resource_path_valid = value
	_valid_form()


func _valid_form() -> void:
	if project_path_valid and resource_path_valid and not project_name_field.text.empty():
		save_button.disabled = false
	else:
		save_button.disabled = true


func _on_Save() -> void:
	var values := {
		"path":
		{
			"name": form_values.project_name,
			"project": "%s/%s.cfg" % [form_values.project_path, form_values.project_name],
			"resource": form_values.resource_path,
		}
	}
	Config.new_project(values, values.path.project)
	Events.emit_signal("projects_list_changed")
	_on_Cancel()


func _on_Cancel() -> void:
	self.project_path_valid = false
	self.resource_path_valid = false
	form_values = INITIAL_VALUE.duplicate(true)
	project_name_field.text = ""
	project_path_field.value = ""
	resource_path_field = ""
	hide()


func _on_Text_changed(new_text: String) -> void:
	form_values.project_name = new_text
	_valid_form()
