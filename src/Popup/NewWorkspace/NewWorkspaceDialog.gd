extends WindowDialog

const INITIAL_VALUE := {
	"name": "",
	"folder": "",
	"resource": "",
	"configuration":
	{
		"has_portrait": true,
		"has_name": true,
		"dialogue_character_limit": 0,
		"choice_character_limit": 0
	}
}

var form_values := INITIAL_VALUE.duplicate(true)
var folder_valid := false setget set_folder_valid
var resource_valid := false setget set_resource_valid

onready var name_field := $MarginContainer/Content/NameField
onready var folder_path_field = $MarginContainer/Content/FolderPathFieldContainer/FolderPathField
onready var resource_path_field = $MarginContainer/Content/ResourcePathFieldContainer/ResourcePathField
onready var portait_checkbox = $MarginContainer/Content/DialogueSettingsContainer/CheckboxContainer/PortaitCheckButton
onready var name_checkbox = $MarginContainer/Content/DialogueSettingsContainer/CheckboxContainer/NameCheckButton
onready var dialogue_character_limit_field = $MarginContainer/Content/DialogueSettingsContainer/CharacterLimit/SpinBox
onready var choice_character_limit_field = $MarginContainer/Content/ChoiceSettingsContainer/SpinBox
onready var cancel_button := $MarginContainer/Content/MarginContainer/ActionsField/CancelWorkspaceButton
onready var save_button := $MarginContainer/Content/MarginContainer/ActionsField/SaveNewWorkspaceButton


func _ready() -> void:
	Events.connect("new_workspace_dialog_displayed", self, "popup")
	name_field.connect("text_changed", self, "_on_Text_changed")
	cancel_button.connect("pressed", self, "_on_Cancel")
	save_button.connect("pressed", self, "_on_Save")
	portait_checkbox.connect("toggled", self, "_on_Dialogue_portrait_toggled")
	name_checkbox.connect("toggled", self, "_on_Dialogue_name_toggled")
	dialogue_character_limit_field.connect(
		"value_changed", self, "_on_Dialogue_character_limit_value_changed"
	)
	choice_character_limit_field.connect(
		"value_changed", self, "_on_Choice_character_limit_value_changed"
	)


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
			OS.get_name(): form_values.resource,
		},
		"configuration": form_values.configuration.duplicate(true)
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


func _on_Dialogue_portrait_toggled(button_pressed: bool) -> void:
	form_values.configuration.has_portrait = button_pressed


func _on_Dialogue_name_toggled(button_pressed: bool) -> void:
	form_values.configuration.has_name = button_pressed


func _on_Dialogue_character_limit_value_changed(value: float) -> void:
	form_values.configuration.dialogue_character_limit = int(value)


func _on_Choice_character_limit_value_changed(value: float) -> void:
	form_values.configuration.choice_character_limit = int(value)
