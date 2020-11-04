extends VBoxContainer

onready var portrait := $CenterContainer/Portrait
onready var portrait_name := $PortraitName
onready var delete := $HBoxContainer/Delete
onready var default := $HBoxContainer/DefaultButton

var values := {}


func _ready() -> void:
	portrait_name.connect("text_changed", self, "_on_Text_changed")
	default.connect("toggled", self, "_on_Default_toggled")
	delete.connect("pressed", self, "_on_Delete_pressed")


func _on_Default_toggled(button_pressed: bool) -> void:
	if not button_pressed:
		values.erase("default")
		return
	values["default"] = button_pressed
	get_parent().change_default_portrait(self)


func _on_Delete_pressed() -> void:
	get_parent().owner.form_values.portraits.erase(values)
	queue_free()


func _on_Text_changed(new_text: String) -> void:
	values["name"] = new_text
