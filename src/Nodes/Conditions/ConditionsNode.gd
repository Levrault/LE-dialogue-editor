extends GraphEditorNode

const TYPE = Editor.Type.condition
const SLOT = 0

var condition_field := preload("res://src/Nodes/Fields/Conditions.tscn")

onready var input := $Container/FieldContainer/Input
onready var add_field = $Container/FieldContainer/AddCondition
onready var field_container = $Container/FieldContainer
onready var is_empty = $Container/IsEmpty

var right_dialogue_connection := ""


func _ready() -> void:
	is_empty.connect("toggled", self, "_on_Toggled")
	add_field.is_disabled = true


# prevent addind an existing value
func has_duplicate_value(value: String) -> bool:
	for v in values.data:
		if v == value:
			return true
	return false


func callback() -> void:
	var keys = values.data.keys()
	keys.erase("next")
	if keys.size() > 0:
		is_empty.hide()
	else:
		is_empty.show()


func _on_Close_request() -> void:
	._on_Close_request()
	Store.conditions_node.erase(uuid)


func _on_Deleted(value_to_delete: String, field_rect_size: Vector2) -> void:
	._on_Deleted(value_to_delete, field_rect_size)
	Events.emit_signal("condition_value_deleted", value_to_delete)
	callback()


func _on_File_loaded() -> void:
	for value in values.data:
		# do not add editor data
		if value == "next":
			continue
		var new_condition = condition_field.instance()
		container.add_child(new_condition)
		new_condition.value.text = value
		new_condition.connect("field_deleted", self, "_on_Deleted")
		Events.emit_signal("condition_value_added")

	if values.__editor.has("collapsed") and values.__editor.collapsed:
		field_container.hide()
		is_empty.pressed = true

	is_loading = false


func _on_Toggled(button_pressed: bool) -> void:
	values.__editor["collapsed"] = button_pressed
	if button_pressed:
		field_container.hide()
		rect_size = Vector2(100, 40)
		return
	field_container.show()
