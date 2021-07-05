# Create, edit and delete a character
# Used by many sub-script (addPortraitButton, CharacterContainer, SaveCharacter)
# Edit mode is manage with the Dictionary reference system of Godot. I just
# directly load the dictionary (without duplicate), so the ref is still the same
# and I can directly edit the dictionary (will also update in Config autoload)
extends WindowDialog

var label_scene := preload("res://src/Components/Label.tscn")

var initial_form_values := {"name": "", "portraits": []}
var form_values := initial_form_values.duplicate()
var characters: Array = Config.values.variables.characters
var is_edit_character_mode := false

onready var portrait_file_dialog := $PortraitFileDialog
onready var name_edit := $MarginContainer/ContentContainer/CharacterFormContainer/NameEdit
onready var import_container := $MarginContainer/ContentContainer/CharacterFormContainer/PortraitField/ImportContainer/ScrollContainer/ImportContainer
onready var save_character := $MarginContainer/ContentContainer/CharacterFormContainer/HBoxContainer/SaveCharacter
onready var cancel_character := $MarginContainer/ContentContainer/CharacterFormContainer/HBoxContainer/CancelCharacter
onready var delete_character := $MarginContainer/ContentContainer/CharacterFormContainer/HBoxContainer/DeleteCharacter
onready var characters_container := $MarginContainer/ContentContainer/ListContainer/ScrollContainer/MarginContainer/CharactersContainer


func _ready() -> void:
	Events.connect("characters_list_changed", characters_container, "_on_Config_changed")
	Events.connect("characters_pop_up_displayed", self, "popup")
	portrait_file_dialog.current_dir = Config.values.path[OS.get_name()]


func reset_form() -> void:
	name_edit.text = ""
	import_container.clean()
	form_values = initial_form_values.duplicate(true)
	is_edit_character_mode = false
	delete_character.hide()
	cancel_character.hide()
	save_character.disabled = true

	for btn in characters_container.get_children():
		btn.pressed = false


# Manage character edition. Button is passed to unpressed the previous edited character
# @param {bool} 		button_pressed
# @param {ToolButton} 	ref - current clicked button
func _on_Character_toggled(button_pressed: bool, ref: ToolButton) -> void:
	if not button_pressed:
		is_edit_character_mode = false
		reset_form()
		return

	for btn in characters_container.get_children():
		if btn == ref:
			continue
		btn.pressed = false

	name_edit.text = ref.values.name
	import_container.clean()

	for portrait in ref.values.portraits:
		import_container.add_item(portrait, true)
	form_values = ref.values
	delete_character.show()
	cancel_character.show()
	save_character.disabled = false
	is_edit_character_mode = true
