extends Control

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

# form
onready var step_1_container := $MarginContainer/Content/CenterContainer/FormStep1
onready var step_2_container := $MarginContainer/Content/CenterContainer/FormStep2

# field
onready var name_field := $MarginContainer/Content/CenterContainer/FormStep1/NameField
onready var folder_path_field = $MarginContainer/Content/CenterContainer/FormStep1/FolderPathFieldContainer/FolderPathField
onready var resource_path_field = $MarginContainer/Content/CenterContainer/FormStep1/ResourcePathFieldContainer/ResourcePathField
onready var dialogue_character_limit_field = $MarginContainer/Content/CenterContainer/FormStep2/CharacterLimit/CharacterLimitField
onready var choice_character_limit_field = $MarginContainer/Content/CenterContainer/FormStep2/ChoiceSettingsContainer/CharacterLimitField
onready var dialogue_type = $MarginContainer/Content/CenterContainer/FormStep2/DialogueType

# buttons
onready var to_step1_button := $MarginContainer/Content/CenterContainer/FormStep2/MarginContainer/ActionsField/ToStep1Button
onready var to_step2_button := $MarginContainer/Content/CenterContainer/FormStep1/MarginContainer/ActionsField/ToStep2Button
onready var go_back_button := $MarginContainer/Content/Navigation/GoBackButton
onready var save_button := $MarginContainer/Content/CenterContainer/FormStep2/MarginContainer/ActionsField/SaveNewWorkspaceButton


func _ready() -> void:
	Events.connect("workspace_new_form_displayed", self, "show")

	# fields
	dialogue_character_limit_field.connect(
		"value_changed", self, "_on_Dialogue_character_limit_value_changed"
	)
	choice_character_limit_field.connect(
		"value_changed", self, "_on_Choice_character_limit_value_changed"
	)
	dialogue_type.connect("changed", self, "_on_Dialogue_type_changed")

	# button signals
	to_step1_button.connect("pressed", self, "_on_Step1_pressed")
	to_step2_button.connect("pressed", self, "_on_Step2_pressed")
	name_field.connect("text_changed", self, "_on_Text_changed")
	go_back_button.connect("pressed", self, "_on_Go_back_pressed")
	save_button.connect("pressed", self, "_on_Save")

	step_1_container.show()
	step_2_container.hide()


func set_folder_valid(value: bool) -> void:
	folder_valid = value
	validate_step_1_values()


func set_resource_valid(value: bool) -> void:
	resource_valid = value
	validate_step_1_values()


func validate_step_1_values() -> void:
	if folder_valid and resource_valid and not name_field.text.empty():
		to_step2_button.disabled = false
		return
	to_step2_button.disabled = true


func _on_Save() -> void:
	var values := {
		"path":
		{
			"name": form_values.name,
			"folder": "%s/%s.cfg" % [form_values.folder, form_values.name],
			"resource": form_values.resource,
			OS.get_name(): form_values.resource,
			"has_portrait": form_values.configuration.has_portrait,
			"has_name": form_values.configuration.has_name
		},
		"configuration": form_values.configuration.duplicate(true)
	}

	Config.new_workspace(values, values.path.folder)
	Events.emit_signal("recents_table_changed")
	_on_Go_back_pressed()


func _on_Go_back_pressed() -> void:
	self.folder_valid = false
	self.resource_valid = false
	form_values = INITIAL_VALUE.duplicate(true)
	name_field.text = ""
	folder_path_field.value = ""
	resource_path_field.value = ""
	dialogue_type.get_child(0).pressed = true
	step_1_container.show()
	step_2_container.hide()
	hide()


func _on_Step1_pressed() -> void:
	step_1_container.show()
	step_2_container.hide()


func _on_Step2_pressed() -> void:
	step_2_container.show()
	step_1_container.hide()


func _on_Text_changed(new_text: String) -> void:
	form_values.name = new_text
	validate_step_1_values()


func _on_Dialogue_character_limit_value_changed(value: float) -> void:
	form_values.configuration.dialogue_character_limit = int(value)


func _on_Choice_character_limit_value_changed(value: float) -> void:
	form_values.configuration.choice_character_limit = int(value)


func _on_Dialogue_type_changed(value: String) -> void:
	if value == "complete":
		form_values.configuration.has_portrait = true
		form_values.configuration.has_name = true
		return

	if value == "basic":
		form_values.configuration.has_portrait = false
		form_values.configuration.has_name = true
		return

	form_values.configuration.has_portrait = false
	form_values.configuration.has_name = false
