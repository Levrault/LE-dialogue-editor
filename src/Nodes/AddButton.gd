extends Button
class_name AddButton

var is_disabled := false setget set_is_disabled

onready var tween := $Tween


func _ready() -> void:
	connect("pressed", self, "on_Pressed")


func set_is_disabled(value: bool) -> void:
	is_disabled = value
	disabled = value
	var rotation = 45 if value else 0
	tween.interpolate_property(self, "rect_rotation", rect_rotation, rotation, .2)
	tween.start()


func on_Pressed() -> void:
	pass
