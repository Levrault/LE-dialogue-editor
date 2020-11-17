extends ToolButton
class_name AnimatedToolButton

const DURATION := .25
const COLOR = Color(1, 1, 1, .6)
const COLOR_HOVER = Color(1, 1, 1, 1)

var selected := false setget set_selected

onready var tween := $Tween


func _ready() -> void:
	modulate = COLOR
	connect("mouse_entered", self, "_on_Mouse_entered")
	connect("mouse_exited", self, "_on_Mouse_exited")


func set_selected(value: bool) -> void:
	selected = value

	if selected:
		_on_Mouse_entered()
		return

	_on_Mouse_exited()


func _on_Mouse_entered() -> void:
	tween.interpolate_property(
		self, "modulate", modulate, COLOR_HOVER, DURATION, Tween.EASE_IN, Tween.EASE_OUT
	)
	tween.start()


func _on_Mouse_exited() -> void:
	if selected:
		return
	tween.interpolate_property(
		self, "modulate", modulate, COLOR, DURATION, Tween.EASE_IN, Tween.EASE_OUT
	)
	tween.start()
