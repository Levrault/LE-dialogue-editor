extends ConfirmationDialog


func _ready() -> void:
	Events.connect(
		"confirmation_relation_pop_up_displayed", self, "_on_Confirmation_relation_pop_up_displayed"
	)
	connect("confirmed", self, "_on_Confirmed")
	get_cancel().connect("pressed", self, "_on_Close_pressed")


func _on_Confirmation_relation_pop_up_displayed(text: String) -> void:
	dialog_text = text
	popup()


func _on_Confirmed() -> void:
	Events.emit_signal("confirmation_relation_answered", true)


func _on_Close_pressed() -> void:
	Events.emit_signal("confirmation_relation_answered", false)
