extends VBoxContainer

onready var _name := get_name().to_lower()
onready var en_field := $EnContainer/En
onready var fr_field := $FrContainer/Fr

func _ready() -> void:
	en_field.connect("text_changed", self, "_on_En_text_changed")
	fr_field.connect("text_changed", self, "_on_Fr_text_changed")


func _on_En_text_changed() -> void:
	owner.values[_name].en = en_field.text


func _on_Fr_text_changed() -> void:
	owner.values[_name].fr = fr_field.text
