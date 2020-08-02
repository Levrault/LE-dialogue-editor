extends GraphEdit


func _ready() -> void:
	connect("connection_request", self, "_on_Connection_request")


func _on_Connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	var from_node = get_node(from)
	var to_node = get_node(to)

	# choice to dialogue relation
	if from_node.TYPE == Editor.Type.choice and to_node.TYPE == Editor.Type.choice:
		print_debug("ERROR: choice to choice relation")
		# TODO: ADD warning message
		return

	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.dialogue:
		print_debug("connect dialogue to dialogue relation")
		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_dialogue_relation_created", from_node.uuid, to_node.uuid)
		return

	# dialogue to choice relation
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.choice:
		print_debug("connect dialogue to choice relation")
		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_choice_relation_created", from_node.uuid, to_node.uuid)
		return

	# choice to dialogue relation
	if from_node.TYPE == Editor.Type.choice and to_node.TYPE == Editor.Type.dialogue:
		print_debug("connect choice to dialogue relation")
		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("choice_to_dialogue_relation_created", from_node.uuid, to_node.uuid)
		return
