extends GraphEditorNode

const TYPE = Editor.Type.condition

var values := {}

onready var container := $Container
onready var input := $Container/FieldContainer/Input
onready var add_field = $Container/FieldContainer/AddCondition


func _ready() -> void:
	add_field.is_disabled = true


# prevent addind an existing value
func has_duplicate_value(value: String) -> bool:
	for v in values:
		if v == value:
			return true
	return false


# Remove delete value from values dictionnary
# and use rect_size to resize the node
func _on_Condition_deleted(value_to_delete: String, field_rect_size: Vector2) -> void:
	values.erase(value_to_delete)
	print(rect_size)
	container.rect_size = Vector2(container.rect_size.x, container.rect_size.y - field_rect_size.y)
	rect_size = Vector2(rect_size.x, rect_size.y - (field_rect_size.y * 2))

	print(rect_size)
