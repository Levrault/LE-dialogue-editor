extends Label


func _ready() -> void:
	Events.connect("file_title_changed", self, "_on_File_tile_changed")


func _on_File_tile_changed(title: String) -> void:
	text = title
