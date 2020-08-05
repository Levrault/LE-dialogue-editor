extends HBoxContainer

signal field_deleted(value, rect_size)

onready var value := $Value


func delete() -> void:
	print("field_deleted")
	emit_signal("field_deleted", value.text, self.rect_size)
	queue_free()
