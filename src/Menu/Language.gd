extends MenuButton

func _ready():
	get_popup().connect("id_pressed", self, "_on_Item_pressed")
	get_popup().add_item("en")
	get_popup().add_item("fr")


func _on_Item_pressed(id: int) -> void:
	var action := get_popup().get_item_text(id)
	Events.emit_signal("change_language", action)
	
