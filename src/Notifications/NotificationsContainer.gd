extends Control

var notification := preload("res://src/Notifications/Notification.tscn")
var notification_warning := preload("res://src/Notifications/NotificationWarning.tscn")
var notification_error := preload("res://src/Notifications/NotificationError.tscn")
var notification_success := preload("res://src/Notifications/NotificationSuccess.tscn")

onready var container := $Container


func _ready() -> void:
	Events.connect("notification_displayed", self, "_on_Notification_displayed")


func _on_Notification_displayed(type: int, message: String) -> void:
	var new_notification = null
	match type:
		Editor.Notification.idle:
			new_notification = notification.instance()
		Editor.Notification.error:
			new_notification = notification_error.instance()
		Editor.Notification.warning:
			new_notification = notification_warning.instance()
		Editor.Notification.success:
			new_notification = notification_success.instance()
	container.add_child(new_notification)
	new_notification.label.text = message
