extends VBoxContainer

var condition_checkbox := preload("res://src/Preview/ConditionCheckBox.tscn")

var conditions := {}

onready var label := $Label

func _ready() -> void:
	Events.connect("condition_value_added", self, "_on_Condition_value_added")
	Events.connect("condition_value_deleted", self, "_on_Condition_value_deleted")


# sync with all conditions field values
func _on_Condition_value_added() -> void:
	if not owner.visible:
		return
	label.hide()
	for key in Store.conditions_node:
		for data in Store.conditions_node[key].data:
			if not conditions.has(data):
				conditions[data] = true
				var condition_checkbox_field := condition_checkbox.instance()
				condition_checkbox_field.text = data
				condition_checkbox_field.name = data
				add_child(condition_checkbox_field)


# remove a value only when it does not exist in all conditions node
func _on_Condition_value_deleted(value: String) -> void:
	if not owner.visible:
		return

	for field in get_children():
		for key in Store.conditions_node:
			if Store.conditions_node[key].data.has(value):
				return

	get_node(value).queue_free()
	
	# since queue_free only set on the next frame
	if get_child_count() == 2:
		label.show()
