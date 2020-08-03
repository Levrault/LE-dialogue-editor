extends WindowDialog

onready var json := $Container/Json


func _ready():
	connect("about_to_show", self, "_on_About_to_show")


func _on_About_to_show() -> void:
	json.bbcode_text = Json.bbcode_to_string()
