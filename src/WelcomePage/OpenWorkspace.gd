extends AnimatedToolButton


func _ready() -> void:
	connect("pressed", Events, "emit_signal", ["workspace_open_file_dialog_displayed"])
