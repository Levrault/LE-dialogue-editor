extends ToolButton

var condition := preload("res://src/Nodes/Fields/Conditions.tscn")
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
	if owner.input.text.empty():
		return

	# add values
	owner.values[owner.input.text] = true

	# add field
	var new_condition := condition.instance()
	owner.container.add_child(new_condition)
	new_condition.value.text = owner.input.text
	new_condition.connect("field_deleted", owner, "_on_Condition_deleted")

	# set for next conditions
	owner.input.text = ""
	owner.add_condition.is_disabled = true
