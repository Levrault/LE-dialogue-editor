extends LineEdit


func _ready() -> void:
	connect("text_changed", self, "_on_Text_changed")


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		owner.add_condition.on_Pressed()


func _on_Text_changed(new_text: String) -> void:
	if new_text == "":
		owner.add_condition.is_disabled = true
		return
	if owner.has_duplicate_value(text):
		owner.add_condition.is_disabled = true
		return

	owner.add_condition.is_disabled = false
