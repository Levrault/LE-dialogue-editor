# Conditions will add the conditions params to the left connected node.
# Conditions determines when the right node can be displayed
#
# Generated json
#   "conditions": [
#      { "next": "fd6200dc-6623-4e20-96a0-61ba6632be15" },
#      {
#        "live": { "value": 3, "operator": "equal", "type": "int" },
#        "next": "7c7d4384-8bc4-487f-b560-98184ec06141"
#      },
#    ],
extends GraphEditorNode

enum Type { boolean, number }
const FOLD_TIME := .075
const TYPE = Editor.Type.condition
const SLOT = 0

var condition_field := preload("res://src/Nodes/Fields/ConditionItem.tscn")
var selected_type = Type.boolean

onready var field_container := $Container/FieldContainer
onready var type_container := $Container/TypeContainer
onready var input := $Container/FieldContainer/Input
onready var add_field := $Container/HBoxContainer/AddCondition
onready var is_empty := $Container/IsEmpty
onready var type_option := $Container/TypeContainer/TypeOption
onready var boolean_field := $Container/BooleanField
onready var number_field := $Container/NumberOptionsField
onready var fold_container := $Container/FoldContainer
onready var fold_button := $Container/FoldContainer/Fold
onready var unfold_button := $Container/FoldContainer/UnFold

var left_dialogues_connection := []
var right_dialogue_connection := ""
var right_choice_connection := ""


func _ready() -> void:
	is_empty.connect("toggled", self, "_on_Toggled")
	fold_button.connect("pressed", self, "_on_Fold_pressed")
	unfold_button.connect("pressed", self, "_on_UnFold_pressed")

	type_option.connect("item_selected", self, "_on_Type_selected")
	type_option.add_item("Boolean", Type.boolean)
	type_option.add_item("Number", Type.number)
	type_option.selected = Type.boolean
	add_field.is_disabled = true
	fold_button.show()
	unfold_button.hide()


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


func is_submitable() -> bool:
	if selected_type == Type.number and not number_field.is_valid():
		return false
	return true


func on_Close_request() -> void:
	.on_Close_request()
	Store.conditions_node.erase(uuid)


func _on_Type_selected(index: int) -> void:
	selected_type = index
	if index == Type.boolean:
		add_field.is_disabled = true
		boolean_field.show()
		number_field.hide()
		return

	if index == Type.number:
		add_field.is_disabled = true
		number_field.show()
		boolean_field.hide()
		return


func _on_Toggled(button_pressed: bool) -> void:
	values.__editor["collapsed"] = button_pressed
	if button_pressed:
		field_container.hide()
		type_container.hide()
		number_field.hide()
		boolean_field.hide()
		add_field.hide()
		fold_container.hide()
		rect_size = Vector2(100, 40)
		return
	field_container.show()
	type_container.show()
	add_field.show()
	fold_container.show()
	fold_button.show()
	unfold_button.hide()

	if selected_type == Type.boolean:
		boolean_field.show()
		return
	if selected_type == Type.number:
		number_field.show()
		return


func _on_Fold_pressed() -> void:
	unfold_button.show()
	fold_button.hide()
	type_container.hide()
	field_container.hide()
	boolean_field.hide()
	number_field.hide()
	add_field.hide()
	rect_size = Vector2(100, 40)
	values.__editor["folded"] = true


func _on_UnFold_pressed() -> void:
	fold_button.show()
	unfold_button.hide()
	field_container.show()
	type_container.show()
	boolean_field.show()
	number_field.hide()
	add_field.show()
	values.__editor["folded"] = false


func _on_Deleted(value_to_delete: String, field_rect_size: Vector2) -> void:
	._on_Deleted(value_to_delete, field_rect_size)
	Events.emit_signal("condition_value_deleted", value_to_delete)
	callback()


func _on_File_loaded() -> void:
	for name in values.data:
		# do not add editor data
		if name == "next" or name == "parent":
			continue
		var new_condition = condition_field.instance()
		container.add_child(new_condition)
		new_condition.name_field.text = name
		new_condition.value.text = String(values.data[name].value)
		new_condition.operator.text = String(values.data[name].operator)
		new_condition.connect("field_deleted", self, "_on_Deleted")
		Events.emit_signal("condition_value_added")

	var folded = values.__editor.get("folded")
	if folded:
		unfold_button.show()
		fold_button.hide()
		type_container.hide()
		field_container.hide()
		boolean_field.hide()
		number_field.hide()
		add_field.hide()
		is_empty.show()

	var collapsed = values.__editor.get("collapsed")
	if collapsed:
		unfold_button.hide()
		fold_button.hide()
		type_container.hide()
		field_container.hide()
		boolean_field.hide()
		number_field.hide()
		add_field.hide()
		is_empty.show()
		is_empty.pressed = true
	else:
		is_empty.hide()

	rect_size = Vector2(100, 20)
	is_loading = false
