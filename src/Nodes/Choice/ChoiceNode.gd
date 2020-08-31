extends GraphEditorNode

const TYPE = Editor.Type.choice


func _ready() -> void:
	if not is_loading:
		values = {
			"__editor": {"uuid": uuid, "offset": [offset.x, offset.y]},
			"data": {"text": {"en": "", "fr": ""}, "next": ""}
		}
