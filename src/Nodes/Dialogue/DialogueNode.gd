extends GraphEditorNode

const TYPE = Editor.Type.dialogue

var connected_to_dialogue := ""
var connected_to_dialogue_slot := 0

var connected_to_conditions := []
var connected_to_condition_slot := 0

var connected_to_choices := []
var connected_to_choices_slot := 0

var connected_to_signal := ""
var connected_to_signal_slot := 0


func _ready() -> void:
	if not is_loading:
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
		dialogue.data.next = ""
		Events.emit_signal("node_deleted", dialogue.__editor.uuid, 0, uuid, 0)

	# clean valid conditions
	for condition in Store.get_connected_nodes(Store.conditions_node, uuid):
		Events.emit_signal(
			"node_deleted", uuid, 0, condition.__editor.uuid, connected_to_condition_slot
		)

	if not connected_to_signal.empty():
		Events.emit_signal("node_deleted", uuid, 0, connected_to_signal, connected_to_signal_slot)
		connected_to_signal = ""

	._on_Close_request()
