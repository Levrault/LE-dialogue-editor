# Choose the portrait for a character
# Rules
# - If the portrait is pristine default portrait will change when 
#   the character's default portrait is changed
# - If the portrait is not pristine, default portrait will not change when
#   the character's default portrait is changed
# - If all the portrait are deleted from the character, a placeholder image is set and the option 
#	is hidden
# - If the portrait is deleted but there is still other portrait, the first one is taken
extends OptionButton
class_name PortraitOptions

const OPTION_IMG_SIZE := Vector2(32, 32)
const PREVIEW_IMG_SIZE := Vector2(108, 108)

var PLACEHOLDER_IMAGE_PATH := "res://assets/icons/user.svg"

var name_selected := ''
var portrait_selected := ''
var pristine := true

onready var empty_msg := get_parent().get_node("Empty")


func _ready() -> void:
	yield(owner, "ready")

	Events.connect("characters_list_changed", self, "_on_Character_list_changed")
	connect("item_selected", self, "_on_Portrait_selected")
	owner.character_name_option.connect(
		"character_selection_changed", self, "_on_Character_selection_changed"
	)

	if owner.character_name_option.get_item_count() > 0:
		_on_Character_selection_changed(
			owner.character_name_option.get_item_text(owner.character_name_option.selected)
		)


func _on_Character_list_changed() -> void:
	# re create the list
	_on_Character_selection_changed(
		owner.character_name_option.get_item_text(owner.character_name_option.selected)
	)

	# display empty message if there is no character left
	if Config.values.variables.characters.empty():
		owner.portrait_placeholder.show()
		owner.portrait_preview.hide()
		empty_msg.show()
		hide()
		return

	# Portrait was deleted 
	var portrait_has_been_deleted := true
	var character: Dictionary = Config.get_character(name_selected)

	if character.empty():
		hide()
		empty_msg.show()
		return

	for portrait in character.portraits:
		if portrait.uuid == portrait_selected:
			portrait_has_been_deleted = false
			break
		portrait_has_been_deleted = true

	if portrait_has_been_deleted:
		_on_Portrait_selected(0)
		return

	if not pristine:
		return

	if get_selected_metadata().uuid != portrait_selected:
		owner.portrait_placeholder.show()
		owner.portrait_preview.hide()


# Clean the list and create all the portrait selection
# @param {String} name
func _on_Character_selection_changed(name: String) -> void:
	if not owner.is_loading:
		FileManager.dirty()
	clear()
	name_selected = name
	pristine = true

	# display empty message if there is no character left
	if Config.values.variables.characters.empty():
		empty_msg.show()
		hide()
		return

	var character: Dictionary = Config.get_character(name)

	if character.empty():
		return

	# display empty message if there is no portraits left
	if character.portraits.empty():
		owner.portrait_placeholder.show()
		owner.portrait_preview.hide()

		hide()
		empty_msg.show()
		return

	# Has the value the create the option list
	show()
	empty_msg.hide()

	var has_default_img := false
	var has_current_portrait := false
	var default_portait_index := 0
	for portrait in character.portraits:
		add_icon_item(Editor.import_image(portrait.path, OPTION_IMG_SIZE), portrait.name)
		set_item_metadata(get_item_count() - 1, {uuid = portrait.uuid, path = portrait.path})

		if portrait.path == owner.values.data.portrait:
			selected = get_item_count() - 1
			_on_Portrait_selected(selected)
			continue

		if portrait.has("default") and pristine:
			default_portait_index = get_item_count() - 1
			has_default_img = true

	if not has_default_img and pristine:
		_on_Portrait_selected(0)

	# no saved data, load default
	if pristine:
		_on_Portrait_selected(default_portait_index)


func _on_Portrait_selected(index: int) -> void:
	if get_item_count() == 0:
		return

	if not owner.is_loading:
		FileManager.dirty()

	var path = get_item_metadata(index).path
	portrait_selected = get_item_metadata(index).uuid
	owner.portrait_preview.texture = Editor.import_image(path, PREVIEW_IMG_SIZE)
	owner.portrait_preview.show()
	owner.portrait_placeholder.hide()

	# Pristine set the default image if not the saved value is loaded
	if pristine:
		pristine = false
		return
	owner.values.data.portrait = path
