extends LineEdit
class_name FieldInput

export var is_number := false
export var can_have_duplicate := false


func _ready() -> void:
	connect("text_changed", self, "_on_Text_changed")


func _on_Text_changed(new_text: String) -> void:
	if new_text == "":
		get_parent().owner.add_field.is_disabled = true
		return
	if not can_have_duplicate and get_parent().owner.has_duplicate_value(text):
		get_parent().owner.add_field.is_disabled = true
		return
	if is_number:
		if not text.is_valid_float():
			get_parent().owner.add_field.is_disabled = true
			return
		if not text.is_valid_integer():
			get_parent().owner.add_field.is_disabled = true
			return

	get_parent().owner.add_field.is_disabled = false
