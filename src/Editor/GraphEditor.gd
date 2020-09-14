# Manage node creation and relation creation between them
extends GraphEdit

const NODE_OFFSET := Vector2(120, 120)


func _ready() -> void:
	connect("connection_request", self, "_on_Connection_request")
	connect("disconnection_request", self, "_on_Disconnection_request")
	Events.connect("node_deleted", self, "_on_Disconnection_request")
	Events.connect("connection_request_loaded", self, "_on_Connection_request")
	Events.connect("graph_node_added", self, "_on_Graph_node_added")
	Events.connect("graph_node_loaded", self, "_on_Graph_node_loaded")
	Events.connect("graph_node_selected", self, "_on_Graph_node_selected")
	Events.connect(
		"preview_predicated_route_displayed", self, "_on_Preview_predicated_route_displayed"
	)


func _on_Connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	Editor.current_state = Editor.FileState.unsaved
	var from_node = get_node(from)
	var to_node = get_node(to)

	if from_node.TYPE != Editor.Type.root and from_node.uuid == to_node.uuid:
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"ERROR: A node can't be connected to itself"
		)
		return

	# START -- Conditions
	if from_node.TYPE == Editor.Type.root and to_node.TYPE == Editor.Type.condition:
		_check_node_connection(
			from,
			from_slot,
			Editor.type_to_string(from_node.TYPE),
			to,
			to_slot,
			Editor.type_to_string(to_node.TYPE),
			from_node.connected_to_dialogue,
			from_node.connected_to_dialogue_slot
		)

		from_node.connected_to_dialogue = ""
		from_node.connected_to_dialogue_slot = 0
		from_node.connected_to_conditions.append(to)
		from_node.connected_to_conditions_slot = to_slot
		to_node.values["__editor"]["parent"] = from_node.uuid
		Events.emit_signal("root_to_condition_relation_changed", to_node.uuid)

		connect_node(from, from_slot, to, to_slot)
		return

	# START -- DIALOGUE
	if from_node.TYPE == Editor.Type.root and to_node.TYPE == Editor.Type.dialogue:
		_check_node_connection(
			from,
			from_slot,
			Editor.type_to_string(from_node.TYPE),
			to,
			to_slot,
			Editor.type_to_string(to_node.TYPE),
			from_node.connected_to_dialogue,
			from_node.connected_to_dialogue_slot
		)

		for condition in from_node.connected_to_conditions:
			_check_node_connection(
				from,
				from_slot,
				Editor.type_to_string(from_node.TYPE),
				to,
				to_slot,
				Editor.type_to_string(to_node.TYPE),
				condition,
				from_node.connected_to_conditions_slot
			)
		# print_debug("connect start to dialogue relation")

		from_node.connected_to_dialogue = to
		from_node.connected_to_dialogue_slot = to_slot
		from_node.connected_to_conditions = []

		Events.emit_signal("root_to_dialogue_relation_changed", to_node.uuid)

		connect_node(from, from_slot, to, to_slot)
		return

	# DIALOGUE -- DIALOGUE
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.dialogue:
		_check_node_connection(
			from,
			from_slot,
			Editor.type_to_string(from_node.TYPE),
			to,
			to_slot,
			Editor.type_to_string(to_node.TYPE),
			from_node.connected_to_dialogue,
			from_node.connected_to_dialogue_slot
		)

		for choices in from_node.connected_to_choices:
			_check_node_connection(
				from,
				from_slot,
				Editor.type_to_string(from_node.TYPE),
				to,
				to_slot,
				Editor.type_to_string(to_node.TYPE),
				choices,
				from_node.connected_to_choices_slot
			)

		# print_debug("connect dialogue to dialogue relation")

		from_node.connected_to_dialogue = to
		from_node.connected_to_dialogue_slot = to_slot
		from_node.connected_to_choices = []

		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_dialogue_relation_created", from_node.uuid, to_node.uuid)
		return

	# DIALOGUE -- SIGNAL  
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.signal_node:
		# print_debug("connect signal to dialogue relation")
		_check_node_connection(
			from,
			from_slot,
			Editor.type_to_string(from_node.TYPE),
			to,
			to_slot,
			Editor.type_to_string(to_node.TYPE),
			from_node.connected_to_signal,
			from_node.connected_to_signal_slot
		)
		from_node.connected_to_signal = to
		from_node.connected_to_signal_slot = to_slot
		to_node.values["__editor"]["parent"] = from_node.uuid

		connect_node(from, from_slot, to, to_slot)
		# in loading mode, store has already the data
		if to_node.is_loading:
			return
		Events.emit_signal("dialogue_to_signal_relation_created", from_node.uuid, to_node.uuid)
		return

	# DIALOGUE -- CHOICE
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.choice:
		# print_debug("connect dialogue to choice relation")
		_check_node_connection(
			from,
			from_slot,
			Editor.type_to_string(from_node.TYPE),
			to,
			to_slot,
			Editor.type_to_string(to_node.TYPE),
			from_node.connected_to_dialogue,
			from_node.connected_to_dialogue_slot
		)

		connect_node(from, from_slot, to, to_slot)
		to_node.values["__editor"]["parent"] = from_node.uuid

		from_node.connected_to_dialogue = ""
		from_node.connected_to_choices.append(to)
		from_node.connected_to_choices_slot = to_slot

		# in loading mode, store has already the data
		if to_node.is_loading:
			return
		Events.emit_signal("dialogue_to_choice_relation_created", from_node.uuid, to_node.uuid)
		return

	# CHOICE -- DIALOGUE
	if from_node.TYPE == Editor.Type.choice and to_node.TYPE == Editor.Type.dialogue:
		# print_debug("connect choice to dialogue relation")
		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("choice_to_dialogue_relation_created", from_node.uuid, to_node.uuid)
		return

	# DIALOGUE -- CONDITIONS
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.condition:
		# print_debug("connect dialogue to condition relation")
		connect_node(from, from_slot, to, to_slot)
		to_node.values["__editor"]["parent"] = from_node.uuid

		# in loading mode, store has already the data
		if to_node.is_loading:
			return
		Events.emit_signal("dialogue_to_condition_relation_created", from_node.uuid, to_node.uuid)
		return

	# CONDITIONS -- DIALOGUE 
	if from_node.TYPE == Editor.Type.condition and to_node.TYPE == Editor.Type.dialogue:
		# print_debug("connect condition to dialogue relation")
		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("condition_to_dialogue_relation_created", from_node.uuid, to_node.uuid)
		return

	Events.emit_signal(
		"notification_displayed",
		Editor.Notification.error,
		(
			"ERROR: %s node can't be linked to a %s node"
			% [Editor.type_to_string(from_node.TYPE), Editor.type_to_string(to_node.TYPE)]
		)
	)


func _on_Disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	Editor.current_state = Editor.FileState.unsaved
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
		return

	# CONDITIONS -- DIALOGUE 
	if from_node.TYPE == Editor.Type.condition and to_node.TYPE == Editor.Type.dialogue:
		print_debug("disconnect choice of dialogue relation")
		disconnect_node(from, from_slot, to, to_slot)
		return

	# DIALOGUE -- CONDITION
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.condition:
		print_debug("disconnect conditions of dialogue relation")
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_condition_relation_deleted", from_node.uuid, to_node.uuid)
		return

	# DIALOGUE -- SIGNAL
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.signal_node:
		print_debug("disconnect signals of dialogue relation")
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_signal_relation_deleted", from_node.uuid)
		return


func _on_Graph_node_added(node: GraphNode) -> void:
	node.offset += scroll_offset + NODE_OFFSET
	node.uuid = Uuid.v4()
	_add_Graph_node(node)
	Editor.current_state = Editor.FileState.unsaved


func _on_Graph_node_loaded(node: GraphNode) -> void:
	node.offset = Vector2(node.values.__editor.offset[0], node.values.__editor.offset[1])
	node.is_loading = true
	_add_Graph_node(node)


func _on_Graph_node_selected(uuid: String) -> void:
	set_selected(get_node(uuid))


func _on_Preview_predicated_route_displayed(uuid_list: Array) -> void:
	for child in get_children():
		if not child is GraphEditorNode:
			continue
		child.selected = false

	for uuid in uuid_list:
		if not has_node(uuid):
			continue
		get_node(uuid).selected = true


# is selected dialogue (from) is already connected to another dialogue
# Can only be connected to ONE dialogue but can be connected to multiple conditions
func _check_node_connection(
	from: String,
	from_slot: int,
	from_type: String,
	to: String,
	to_slot: int,
	to_type: String,
	node_connected: String,
	node_connected_slot: int
) -> void:
	if node_connected.empty():
		return

	print_debug(
		(
			"WARNING: %s %s node is already connected to a %s %s, first connection will be disconnected"
			% [from_type, from, to_type, to]
		)
	)

	Events.emit_signal(
		"notification_displayed",
		Editor.Notification.warning,
		(
			"WARNING: %s node is already connected to a %s, first connection will be disconnected"
			% [from_type, to_type]
		)
	)
	disconnect_node(from, from_slot, node_connected, node_connected_slot)


func _add_Graph_node(node: GraphNode) -> void:
	node.name = node.uuid
	add_child(node)

	if node.TYPE == Editor.Type.root:
		return

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
