extends ToolButton

var texture_rect_scene := preload("res://src/Components/TextureRect.tscn")

var default_portrait := "" setget set_default_portrait
var character_name := "" setget set_character_name
var portraits_list := [] setget set_portraits_list
var values := {} setget set_values

onready var name_label := $Container/Name
onready var default_portrait_rect := $Container/DefaultPortrait
onready var container := $Container


func set_values(new_values: Dictionary) -> void:
	self.character_name = new_values.name
	self.portraits_list = new_values.portraits
	values = new_values


func set_character_name(value: String) -> void:
	character_name = value
	name_label.text = value


func set_default_portrait(value: String) -> void:
	default_portrait = value
	default_portrait_rect.texture = load(value)


func set_portraits_list(values: Array) -> void:
	portraits_list = values
	for value in values:
		var portrait = texture_rect_scene.instance()
		portrait.texture = load(value.path)
		container.add_child(portrait)

		if value.has("default"):
			self.default_portrait = value.path
