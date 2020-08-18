extends LineEdit

onready var _name := get_name().to_lower()


func _ready():
	connect("text_changed", self, "_on_Text_changed")
	Events.connect("file_loaded", self, "_on_File_loaded")


func _on_Text_changed(new_text: String) -> void:
	owner.values[_name] = text


func _on_File_loaded() -> void:
	text = owner.values[_name]
