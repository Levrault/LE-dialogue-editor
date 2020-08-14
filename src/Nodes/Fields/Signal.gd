extends HBoxContainer

signal field_deleted(value, rect_size)

onready var signal_name := $Name
onready var value := $Value
onready var type := $Type


func delete() -> void:
	emit_signal("field_deleted", signal_name.text, self.rect_size)
	queue_free()

