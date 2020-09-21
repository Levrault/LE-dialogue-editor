extends GraphEditorNode

const TYPE = Editor.Type.dialogue

var right_dialogue_connection := ""
var right_dialogue_connection_slot := 0

var left_conditions_connection := ""
var right_connection_slot := []
var connected_to_condition_slot := 0

var right_choices_connection := []
var right_choices_connection_slot := 0

var right_signal_connection := ""
var right_signal_connection_slot := 0


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

	if not right_signal_connection.empty():
		Events.emit_signal(
			"node_deleted", uuid, 0, right_signal_connection, right_signal_connection_slot
		)
		right_signal_connection = ""

	._on_Close_request()
