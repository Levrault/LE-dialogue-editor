extends ScrollContainer


func _ready() -> void:
	$Container/Values.set_process(false)
	$Container/Globals.set_process(false)


func show() -> void:
	visible = true
	$Container/Values.set_process(true)
	$Container/Globals.set_process(true)


func hide() -> void:
	visible = false
	$Container/Values.set_process(false)
	$Container/Globals.set_process(false)
