extends AnimatedToolButton


func _ready() -> void:
	connect("pressed", Events, "emit_signal", ["new_project_dialog_displayed"])
