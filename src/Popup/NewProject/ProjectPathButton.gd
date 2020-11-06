extends AnimatedToolButton

export var line_edit_field_name := ''

func _ready() -> void:
	connect(
		"pressed",
		Events,
		"emit_signal",
		["project_file_dialog_displayed", get_parent().get_node(line_edit_field_name)]
	)
