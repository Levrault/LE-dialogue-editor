extends DialogueEditorNode

const TYPE = Editor.Type.dialogue

onready var container := $Container

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.doubleclick:
		if _is_collapsed:
			rect_size = COLLAPSED_SIZE
		else:
			rect_size = _initial_rect_size
			_is_collapsed = !_is_collapsed
		return


func _on_Resize_request(new_minsize: Vector2) -> void:
	rect_size = new_minsize
	container.rect_size = new_minsize - Vector2(0, SIZE_CONTAINER_BOTTOM_MARGIN)
