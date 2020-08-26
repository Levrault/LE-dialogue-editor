extends ConfirmationDialog


func _ready() -> void:
	Events.connect("unsaved_file_displayed", self, "popup")
	connect("confirmed", self, "_on_Confirmed")
	get_cancel().connect("pressed", self, "_on_Cancel_pressed")


func _on_Confirmed() -> void:
	if Editor.current_state == Editor.FileState.opened:
		Editor.open_file()
		return

	Editor.new_file()


func _on_Cancel_pressed() -> void:
	Editor.current_state = Editor.FileState.unsaved
