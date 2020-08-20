extends GraphEditorNode

const TYPE = Editor.Type.dialogue

var connected_to_dialogue := ""
var connected_to_dialogue_slot := 0

var connected_to_condition := ""
var connected_to_condition_slot := 0

var connected_to_signal := ""
var connected_to_signal_slot := 0



func _ready() -> void:
	if not is_loaded:
		values = {
			"__editor": {"uuid": uuid, "offset": [offset.x, offset.y]},
			"data": {"name": "", "portrait": "", "text": {"en": "", "fr": ""}}
		}
