extends GraphEditorNode

const TYPE = Editor.Type.condition

var condition_field := preload("res://src/Nodes/Fields/Conditions.tscn")

onready var input := $Container/FieldContainer/Input
onready var add_field = $Container/FieldContainer/AddCondition


func _ready() -> void:
	Events.connect("file_loaded", self, "_on_File_loaded")
	add_field.is_disabled = true


# prevent addind an existing value
func has_duplicate_value(value: String) -> bool:
	for v in values:
		if v == value:
			return true
	return false


func _on_File_loaded() -> void:
	for value in values:
		var new_condition = condition_field.instance()
		container.add_child(new_condition)
		yield(new_condition, "ready")
		new_condition.value.text = value
		new_condition.connect("field_deleted", self, "_on_Deleted")
