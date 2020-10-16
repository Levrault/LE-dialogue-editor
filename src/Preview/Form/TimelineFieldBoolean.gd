extends TimelineField

signal checked(name, value)

onready var check_box := $CheckBox
onready var check_button := $CheckButton


func _ready() -> void:
	check_box.connect("toggled", self, "_on_Checkbox_toggled")
	check_button.connect("toggled", self, "_on_Checkbutton_toggled")
	check_box.disabled = true


func _on_Checkbox_toggled(button_pressed: bool) -> void:
	emit_signal("checked", get_name(), button_pressed)


func _on_Checkbutton_toggled(button_pressed: bool) -> void:
	check_box.disabled = not button_pressed
	emit_signal("status_changed", get_name(), button_pressed, check_box.pressed)
