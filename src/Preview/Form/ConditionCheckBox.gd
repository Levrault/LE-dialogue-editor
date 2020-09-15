extends CheckBox

signal checked(name, value)


func _ready() -> void:
	connect("toggled", self, "_on_Toggled")


func _on_Toggled(button_pressed: bool) -> void:
	emit_signal("checked", get_name(), button_pressed)
