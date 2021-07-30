# Generic that create a small flat animated button
extends ToolButton
class_name AnimatedToolButton

const DURATION := .25
const COLOR = Color(1, 1, 1, .6)
const COLOR_HOVER = Color(1, 1, 1, 1)

export var signal_on_pressed := ""

var selected := false setget set_selected

onready var tween := $Tween


func _ready() -> void:
	modulate = COLOR
	connect("mouse_entered", self, "_on_Mouse_entered")
	connect("mouse_exited", self, "_on_Mouse_exited")

	if signal_on_pressed.empty():
		return

	connect("pressed", Events, "emit_signal", [signal_on_pressed])


func set_selected(value: bool) -> void:
	selected = value

	if selected:
		_on_Mouse_entered()
		return

	_on_Mouse_exited()


func _on_Mouse_entered() -> void:
	if disabled:
		return
	tween.interpolate_property(
		self, "modulate", modulate, COLOR_HOVER, DURATION, Tween.EASE_IN, Tween.EASE_OUT
	)
	tween.start()


func _on_Mouse_exited() -> void:
	if selected or disabled:
		return
	tween.interpolate_property(
		self, "modulate", modulate, COLOR, DURATION, Tween.EASE_IN, Tween.EASE_OUT
	)
	tween.start()
