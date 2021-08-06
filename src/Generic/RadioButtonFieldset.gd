extends HBoxContainer

signal changed(value)

var current_checked_child: RadioButton = null


func _ready() -> void:
	assert(get_child_count() != 0)

	for children in get_children():
		if not children is RadioButton:
			continue
		children.pressed = false
		children.connect("toggled", self, "_on_Change", [children])

	current_checked_child = get_child(0)
	current_checked_child.pressed = true


func _on_Change(button_pressed: bool, element: RadioButton) -> void:
	if element.skip_one_shot_update:
		element.skip_one_shot_update = false
		return

	if element == current_checked_child:
		current_checked_child.skip_one_shot_update = true
		current_checked_child.pressed = true
		return

	current_checked_child.skip_one_shot_update = true
	current_checked_child.pressed = false
	element.pressed = true
	current_checked_child = element
	emit_signal("changed", element.name.to_lower())
