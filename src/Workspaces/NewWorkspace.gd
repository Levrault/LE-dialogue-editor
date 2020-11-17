extends AnimatedToolButton


func _ready() -> void:
	connect("pressed", Events, "emit_signal", ["new_workspace_dialog_displayed"])
