extends HBoxContainer

signal field_deleted(value, rect_size)

onready var name_field := $Name
onready var operator := $Operator
onready var value := $Value


func _exit_tree() -> void:
	emit_signal("field_deleted", name_field.text, self.rect_size)


func delete() -> void:
	queue_free()
