# TimelineField input only support int but should be extendable to support
# new type
extends TimelineField

signal changed(name, value)

var type := "int" setget set_type
var integer_regex = RegEx.new()

onready var label := $Label
onready var value := $Value
onready var checkbox := $Checkbox


func _ready() -> void:
	value.connect("text_changed", self, "_on_Text_changed")
	checkbox.connect("toggled", self, "_on_Toggled")
	integer_regex.compile("^[0-9]*$")


func get_value():
	if type == "int":
		if not value.text.empty() and not integer_regex.search(value.text):
			Events.emit_signal(
				"notification_displayed",
				Editor.Notification.error,
				"%s is not an valid integer value" % [value.text]
			)
			return null
		return int(value.text)
	return value.text


func set_type(value: String) -> void:
	type = value.to_lower()


func _on_Text_changed(new_text: String) -> void:
	emit_signal("changed", id, get_value())


func _on_Toggled(button_pressed: bool) -> void:
	value.editable = button_pressed
	emit_signal("status_changed", id, button_pressed, get_value())
