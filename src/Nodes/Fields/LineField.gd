extends LineEdit

onready var _name := get_name().to_lower()


func _ready():
	connect("text_changed", self, "_on_Text_changed")


func _on_Text_changed(new_text: String) -> void:
	owner.values[_name] = text