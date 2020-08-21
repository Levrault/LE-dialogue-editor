# Manage node creation and relation creation between them
extends GraphEdit

const NODE_OFFSET := Vector2(120, 120)


func _ready() -> void:
	connect("connection_request", self, "_on_Connection_request")
	connect("disconnection_request", self, "_on_Disconnection_request")
	Events.connect("node_deleted", self, "_on_Disconnection_request")
	Events.connect("connection_request_loaded", self, "_on_Connection_request")
	Events.connect("graph_node_added", self, "_on_graph_node_added")
	Events.connect("graph_node_loaded", self, "_on_graph_node_loaded")


func _on_Connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	var from_node = get_node(from)
	var to_node = get_node(to)

	# choice to dialogue relation
	if from_node.TYPE == Editor.Type.choice and to_node.TYPE == Editor.Type.choice:
		print_debug("ERROR: choice to choice relation")
		# TODO: ADD warning message
		return

	if from_node.TYPE == Editor.Type.start and to_node.TYPE == Editor.Type.choice:
		print_debug("ERROR: start to choice relation")
		# TODO: ADD warning message
		return

	# start to signal  
	if from_node.TYPE == Editor.Type.start and to_node.TYPE == Editor.Type.signal_node:
		print_debug("ERROR: start to signal relation")
		# TODO: ADD warning message
		return

	# signal to signal  
	if from_node.TYPE == Editor.Type.signal_node and to_node.TYPE == Editor.Type.signal_node:
		print_debug("ERROR: signal to signal relation")
		# TODO: ADD warning message
		return

	# START -- DIALOGUE
	if from_node.TYPE == Editor.Type.start and to_node.TYPE == Editor.Type.dialogue:
		# _check_node_connection(from, from_slot, to, to_slot, from_node, to_node)
		print_debug("connect start to dialogue relation")

		from_node.connected_to_dialogue = to
		from_node.connected_slot = to_slot

		Events.emit_signal("start_to_dialogue_relation_changed", to_node.uuid)

		connect_node(from, from_slot, to, to_slot)
		return

	# DIALOGUE -- CONDITIONS
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.condition:
		_check_node_connection(
			from,
			from_slot,
			to,
			to_slot,
			from_node.connected_to_condition,
			from_node.connected_to_condition_slot
		)
		print_debug("connect dialogue to condition relation")
		from_node.connected_to_condition = to
		from_node.connected_to_condition_slot = to_slot
		to_node.values["__editor"]["parent"] = from_node.uuid
		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_condition_relation_created", from_node.uuid, to_node.uuid)
		return

	# DIALOGUE -- DIALOGUE
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.dialogue:
		_check_node_connection(
			from,
			from_slot,
			to,
			to_slot,
			from_node.connected_to_dialogue,
			from_node.connected_to_dialogue_slot
		)
		print_debug("connect dialogue to dialogue relation")

		from_node.connected_to_dialogue = to
		from_node.connected_to_dialogue_slot = to_slot

		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_dialogue_relation_created", from_node.uuid, to_node.uuid)
		return

	# DIALOGUE -- SIGNAL  
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.signal_node:
		print_debug("connect signal to dialogue relation")
		from_node.connected_to_signal = to
		from_node.connected_to_signal_slot = to_slot
		to_node.values["__editor"]["parent"] = from_node.uuid

		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_signal_relation_created", from_node.uuid, to_node.uuid)
		# TODO: ADD warning message
		return

	# DIALOGUE -- CHOICE
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.choice:
		print_debug("connect dialogue to choice relation")
		connect_node(from, from_slot, to, to_slot)
		to_node.values["__editor"]["parent"] = from_node.uuid
		Events.emit_signal("dialogue_to_choice_relation_created", from_node.uuid, to_node.uuid)
		return

	# CHOICE -- DIALOGUE
	if from_node.TYPE == Editor.Type.choice and to_node.TYPE == Editor.Type.dialogue:
		print_debug("connect choice to dialogue relation")
		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("choice_to_dialogue_relation_created", from_node.uuid, to_node.uuid)
		return


func _on_Disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	var from_node = get_node(from)
	var to_node = get_node(to)
	# DIALOGUE -- DIALOGUE
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.dialogue:
		print_debug("disconnect dialogue of dialogue relation")
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_dialogue_relation_deleted", from_node.uuid)
		return

	# DIALOGUE -- CHOICE
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.choice:
		print_debug("disconnect dialogue of choice relation")
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_choice_relation_deleted", from_node.uuid, to_node.uuid)
		return

	# CHOICE -- DIALOGUE
	if from_node.TYPE == Editor.Type.choice and to_node.TYPE == Editor.Type.dialogue:
		print_debug("disconnect choice of dialogue relation")
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("choice_to_dialogue_relation_deleted", from_node.uuid)
		return

	# DIALOGUE -- CONDITION
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.condition:
		print_debug("disconnect conditions of dialogue relation")
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_condition_relation_deleted", from_node.uuid)
		return

	# DIALOGUE -- SIGNAL
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.signal_node:
		print_debug("disconnect signals of dialogue relation")
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_signal_relation_deleted", from_node.uuid)
		return


func _on_graph_node_added(node: GraphNode) -> void:
	node.offset += scroll_offset + NODE_OFFSET
	node.uuid = Uuid.v4()
	_add_graph_node(node)


func _on_graph_node_loaded(node: GraphNode) -> void:
	node.offset = Vector2(node.values.__editor.offset[0], node.values.__editor.offset[1])
	node.is_loaded = true
	_add_graph_node(node)


# is selected dialogue (from) is already connected to another dialogue
# Can only be connected to ONE dialogue but can be connected to multiple conditions
func _check_node_connection(
	from: String,
	from_slot: int,
	to: String,
	to_slot: int,
	node_connected: String,
	node_connected_slot: int
) -> void:
	if node_connected.empty():
		return

	print_debug(
		(
			"WARNING: %s start is already connected to a dialogue, first connection will be disconnected"
			% from
		)
	)
	disconnect_node(from, from_slot, node_connected, node_connected_slot)


func _add_graph_node(node: GraphNode) -> void:
	node.name = node.uuid
	add_child(node)

	# generate signal to add a new entry inside the json
	if node.TYPE == Editor.Type.choice:
		Events.emit_signal("choice_node_created", {uuid = node.uuid, values = node.values})
		return

	if node.TYPE == Editor.Type.condition:
		Events.emit_signal("condition_node_created", {uuid = node.uuid, values = node.values})
		return

	if node.TYPE == Editor.Type.signal_node:
		Events.emit_signal("signal_node_created", {uuid = node.uuid, values = node.values})
		return

	Events.emit_signal("dialogue_node_created", {uuid = node.uuid, values = node.values})
