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


func _on_Close_request() -> void:
	# remove node connect to choice
	for choice in Store.get_connected_nodes(Store.choices_node, uuid):
		choice.data.next = ""
		Events.emit_signal("node_deleted", choice.__editor.uuid, 0, uuid, 0)

	# remove form other dialogue node
	for dialogue in Store.get_connected_nodes(Store.dialogues_node, uuid):
		print_debug("in")
		dialogue.data.next = ""
		Events.emit_signal("node_deleted", dialogue.__editor.uuid, 0, uuid, 0)

	if not connected_to_condition.empty():
		Events.emit_signal(
			"node_deleted", uuid, 0, connected_to_condition, connected_to_condition_slot
		)
		connected_to_condition = ""

	if not connected_to_signal.empty():
		Events.emit_signal("node_deleted", uuid, 0, connected_to_signal, connected_to_signal_slot)
		connected_to_signal = ""

	._on_Close_request()
