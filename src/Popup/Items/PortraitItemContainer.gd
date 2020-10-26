extends HBoxContainer

var portrait_name := "" setget set_portrait_name
var portrait_path := "" setget set_portrait_path


func set_portrait_name(value: String) -> void:
	portrait_name = value
	$Name.text = value


func set_portrait_path(value: String) -> void:
	portrait_name = value
	$Path.text = value
