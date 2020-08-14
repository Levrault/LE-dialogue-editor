extends HBoxContainer

onready var x := $Vector2X
onready var y := $Vector2Y


func is_valid() -> bool:
	if x.text.empty():
		return false
	if y.text.empty():
		return false
	if not x.text.is_valid_float() or not x.text.is_valid_integer():
		return false
	if not y.text.is_valid_float() or not y.text.is_valid_integer():
		return false
	return true
