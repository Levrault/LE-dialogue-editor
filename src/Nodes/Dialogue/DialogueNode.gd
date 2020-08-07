extends GraphEditorNode

const TYPE = Editor.Type.dialogue

var values := {"name": "", "portrait": "", "text": {"en": "", "fr": ""}}
var connected_to_dialogue := ""
var connected_to_dialogue_slot := 0

var connected_to_condition := ""
var connected_to_condition_slot := 0

onready var container := $Container
