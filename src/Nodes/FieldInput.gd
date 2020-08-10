extends LineEdit
class_name FieldInput

export var is_number := false
export var can_has_duplicate := false


func _ready() -> void:
	connect("text_changed", self, "_on_Text_changed")


func _on_Text_changed(new_text: String) -> void:
	if new_text == "":
		owner.add_field.is_disabled = true
		return
	if not can_has_duplicate and owner.has_duplicate_value(text):
		owner.add_field.is_disabled = true
		return
	if is_number:
		if not text.is_valid_float():
			owner.add_field.is_disabled = true
			return
		if not text.is_valid_integer():
			owner.add_field.is_disabled = true
			return

	owner.add_field.is_disabled = false
