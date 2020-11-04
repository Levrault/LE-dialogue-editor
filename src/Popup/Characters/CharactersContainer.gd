# Create and load existing character
# CharacterItem must directly use the dictionary ref
# It's allow the edition mode to directly change the value in the Config Singleton (thansk dic ref)
extends VBoxContainer

var character_item_scene := preload("res://src/Popup/Characters/CharacterItem.tscn")


func _ready() -> void:
	_on_Config_changed()


func _on_Config_changed() -> void:
	for character in get_children():
		character.queue_free()
	for character in Config.values.variables.characters:
		var item := character_item_scene.instance()
		add_child(item)
		item.values = character
		item.connect("toggled", owner, "_on_Character_toggled", [item])
