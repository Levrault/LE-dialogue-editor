extends ConfirmationDialog


func _ready() -> void:
	Events.connect("unsaved_file_displayed", self, "popup")
	connect("confirmed", self, "_on_Confirmed")
	get_cancel().connect("pressed", self, "_on_Cancel_pressed")


func _on_Confirmed() -> void:
	# TODO: to code
	pass


func _on_Cancel_pressed() -> void:
	FileManager.state = FileManager.previous_state
