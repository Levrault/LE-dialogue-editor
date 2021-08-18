extends AnimatedToolButton


func _ready() -> void:
	hide()


func _unhandled_key_input(event) -> void:
	if event.is_action_pressed("toggle_debug_mode"):
		visible = not visible

		if visible:
			Events.emit_signal(
				"notification_displayed", Editor.Notification.success, "DEBUG ACTIVATED" 
			)
		else:
			Events.emit_signal(
				"notification_displayed", Editor.Notification.error, "DEBUG DESACTIVATED" 
			)
		return