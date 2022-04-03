extends OptionButton

signal character_selection_changed(name)

onready var empty_msg := get_parent().get_node("Empty")


func _ready() -> void:
	if not Config.values.configuration.has_name:
		return

	yield(owner, "ready")
	Events.connect("characters_list_changed", self, "_on_Characters_list_changed")
	connect("item_selected", self, "_on_Character_selected")
	_on_Characters_list_changed()

	if not Config.values.variables.characters.empty():
		emit_signal("character_selection_changed", get_item_text(0))


func _on_Characters_list_changed() -> void:
	clear()

	if Config.values.variables.characters.empty():
		empty_msg.show()
		hide()
		return

	show()
	empty_msg.hide()
	var index := 0
	for character in Config.values.variables.characters:
		add_item(character.name)
		set_item_metadata(get_item_count() - 1, { uuid = character.uuid })
		if character.uuid == owner.values.data.get("character_uuid") or character.name == owner.values.data.name:
			selected = get_item_count() - 1

	owner.values.data.name = get_item_text(selected)
	owner.values.data["character_uuid"] = get_item_metadata(selected).uuid


func _on_Character_selected(index: int) -> void:
	owner.values.data.name = get_item_text(index)
	emit_signal("character_selection_changed", get_item_text(index))
	selected = index
