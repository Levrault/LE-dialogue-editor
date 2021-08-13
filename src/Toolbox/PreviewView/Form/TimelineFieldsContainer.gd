# Manage creation/deletion of the condition's timeline field
extends VBoxContainer

var timeline_field_boolean_scene := preload("res://src/ToolBox/PreviewView/Form/TimelineFieldBoolean.tscn")
var timeline_field_input_scene := preload("res://src/ToolBox/PreviewView/Form/TimelineFieldInput.tscn")
var conditions := {}

onready var label := $Empty


func _ready() -> void:
	Events.connect("condition_value_added", self, "_on_Condition_value_added")
	Events.connect("condition_value_deleted", self, "_on_Condition_value_deleted")


# sync with all conditions field values
func _on_Condition_value_added() -> void:
	if not owner.visible:
		return

	label.hide()
	owner.reset_fold_button()

	for key in Store.conditions_node:
		for data in Store.conditions_node[key].data:
			# prevent adding editor data
			if data == "next" or data == "parent":
				continue
			if not conditions.has(data):
				var values = Store.conditions_node[key].data[data].duplicate(true)
				if values.type == "boolean":
					conditions[data] = true
					var condition_boolean_field := timeline_field_boolean_scene.instance()
					# add boolean at top
					condition_boolean_field.name = data
					condition_boolean_field.id = data
					add_child(condition_boolean_field)
					move_child(condition_boolean_field, 0)

					condition_boolean_field.check_box.text = data
					condition_boolean_field.connect("checked", owner, "_on_Field_checked")
					condition_boolean_field.connect("status_changed", owner, "_on_Status_changed")
					continue

				var condition_input_field := timeline_field_input_scene.instance()
				add_child(condition_input_field)
				condition_input_field.name = data
				condition_input_field.id = data
				condition_input_field.label.text = data
				condition_input_field.type = values.type
				condition_input_field.value.text = String(values.value)
				conditions[data] = values.value
				condition_input_field.connect("changed", owner, "_on_Input_changed")
				condition_input_field.connect("status_changed", owner, "_on_Status_changed")


# remove a value only when it does not exist in all conditions node
func _on_Condition_value_deleted(value: String) -> void:
	if not owner.visible:
		return

	for field in get_children():
		for key in Store.conditions_node:
			if Store.conditions_node[key].data.has(value):
				return

	if not has_node(value):
		return

	owner.conditions.erase(value)
	get_node(value).queue_free()

	# since queue_free only set on the next frame
	if get_child_count() == 2:
		label.show()
