extends AnimatedToolButton

export var line_edit_field_name := ''


func _ready() -> void:
	# prevent parent's connected signal to conflict
	disconnect("pressed", Events, "emit_signal")
	connect(
		"pressed",
		Events,
		"emit_signal",
		[signal_on_pressed, get_parent().get_node(line_edit_field_name)]
	)
