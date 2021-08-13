# Manage node creation and relation creation between them
extends GraphEdit

const NODE_OFFSET := Vector2(120, 120)


func _ready() -> void:
	connect("connection_request", self, "_on_Connection_request")
	connect("disconnection_request", self, "_on_Disconnection_request")
	connect("node_selected", self, "_on_Node_selected")
	Events.connect("node_deleted", self, "_on_Disconnection_request")
	Events.connect("connection_request_loaded", self, "_on_Connection_request")
	Events.connect("graph_node_added", self, "_on_Graph_node_added")
	Events.connect("graph_node_loaded", self, "_on_Graph_node_loaded")
	Events.connect("graph_node_selected", self, "_on_Graph_node_selected")
	Events.connect(
		"preview_predicated_route_displayed", self, "_on_Preview_predicated_route_displayed"
	)


func _on_Connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	Events.emit_signal("preview_button_activated")
	var wait_for_user_confirmation = false  # can be a GDScriptFunctionState

	assert(has_node(from))
	assert(has_node(to))

	var from_node = get_node(from)
	var to_node = get_node(to)

	if not Editor.is_loading:
		FileManager.dirty()

	if from_node == null:
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"ERROR: %s doesn't not exist in the json file" % [from]
		)
		return

	if to_node == null:
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"ERROR: %s doesn't not exist in the json file" % [to]
		)
		return

	if from_node.TYPE != Editor.Type.root and from_node.uuid == to_node.uuid:
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"ERROR: A node can't be connected to itself"
		)
		return

	# keep track of parent based on user's feedback
	to_node.values.data["parent"] = from_node.uuid

	# ROOT -- CONDITIONS
	if from_node.TYPE == Editor.Type.root and to_node.TYPE == Editor.Type.condition:
		wait_for_user_confirmation = _check_node_connection(
			from,
			from_slot,
			Editor.type_to_string(from_node.TYPE),
			to,
			to_slot,
			Editor.type_to_string(to_node.TYPE),
			from_node.right_dialogue_connection,
			from_node.SLOT
		)

		# need user answer
		if wait_for_user_confirmation is GDScriptFunctionState:
			wait_for_user_confirmation = yield(wait_for_user_confirmation, "completed")
		if not wait_for_user_confirmation:
			return

		from_node.right_dialogue_connection = ""
		from_node.right_conditions_connection.append(to)
		to_node.values.__editor["parent"] = from_node.uuid
		Events.emit_signal("root_to_condition_relation_created", to_node.uuid)

		connect_node(from, from_slot, to, to_slot)
		return

	# ROOT -- DIALOGUE
	if from_node.TYPE == Editor.Type.root and to_node.TYPE == Editor.Type.dialogue:
		wait_for_user_confirmation = _check_node_connection(
			from,
			from_slot,
			Editor.type_to_string(from_node.TYPE),
			to,
			to_slot,
			Editor.type_to_string(to_node.TYPE),
			from_node.right_dialogue_connection,
			from_node.SLOT
		)

		# need user answer
		if wait_for_user_confirmation is GDScriptFunctionState:
			wait_for_user_confirmation = yield(wait_for_user_confirmation, "completed")
		if not wait_for_user_confirmation:
			return

		for condition in from_node.right_conditions_connection:
			wait_for_user_confirmation = _check_node_connection(
				from,
				from_slot,
				Editor.type_to_string(from_node.TYPE),
				to,
				to_slot,
				Editor.type_to_string(to_node.TYPE),
				condition,
				from_node.SLOT
			)
			# need user answer
			if wait_for_user_confirmation is GDScriptFunctionState:
				wait_for_user_confirmation = yield(wait_for_user_confirmation, "completed")
			if not wait_for_user_confirmation:
				return

		from_node.right_dialogue_connection = to
		from_node.right_conditions_connection = []
		to_node.values.__editor["parent"] = from_node.uuid

		Events.emit_signal("root_to_dialogue_relation_created", to_node.uuid)

		connect_node(from, from_slot, to, to_slot)
		return

	# DIALOGUE -- DIALOGUE
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.dialogue:
		wait_for_user_confirmation = _check_node_connection(
			from,
			from_slot,
			Editor.type_to_string(from_node.TYPE),
			to,
			to_slot,
			Editor.type_to_string(to_node.TYPE),
			from_node.right_dialogue_connection,
			from_node.SLOT
		)

		# need user answer
		if wait_for_user_confirmation is GDScriptFunctionState:
			wait_for_user_confirmation = yield(wait_for_user_confirmation, "completed")
		if not wait_for_user_confirmation:
			return

		for condition in from_node.right_conditions_connection:
			wait_for_user_confirmation = _check_node_connection(
				from,
				from_slot,
				Editor.type_to_string(from_node.TYPE),
				to,
				to_slot,
				Editor.type_to_string(to_node.TYPE),
				condition,
				from_node.SLOT
			)

			# need user answer
			if wait_for_user_confirmation is GDScriptFunctionState:
				wait_for_user_confirmation = yield(wait_for_user_confirmation, "completed")
			if not wait_for_user_confirmation:
				return

		for choice in from_node.right_choices_connection:
			wait_for_user_confirmation = _check_node_connection(
				from,
				from_slot,
				Editor.type_to_string(from_node.TYPE),
				to,
				to_slot,
				Editor.type_to_string(to_node.TYPE),
				choice,
				from_node.SLOT
			)

			# need user answer
			if wait_for_user_confirmation is GDScriptFunctionState:
				wait_for_user_confirmation = yield(wait_for_user_confirmation, "completed")
			if not wait_for_user_confirmation:
				return

		# Multiple dialogues can point to a dialogue
		to_node.left_dialogues_connection.append(from)

		# But a dialogue can only have one connection on the next dialogue
		from_node.right_dialogue_connection = to

		# if the from dialogue has choice, connection must be deleted
		from_node.right_choices_connection = []

		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_dialogue_relation_created", from_node.uuid, to_node.uuid)
		return

	# DIALOGUE -- SIGNAL
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.signal_node:
		wait_for_user_confirmation = _check_node_connection(
			from,
			from_slot,
			Editor.type_to_string(from_node.TYPE),
			to,
			to_slot,
			Editor.type_to_string(to_node.TYPE),
			from_node.right_signal_connection,
			from_node.SLOT
		)

		# need user answer
		if wait_for_user_confirmation is GDScriptFunctionState:
			wait_for_user_confirmation = yield(wait_for_user_confirmation, "completed")
		if not wait_for_user_confirmation:
			return

		from_node.right_signal_connection = to
		to_node.values.__editor["parent"] = from_node.uuid

		connect_node(from, from_slot, to, to_slot)
		# in loading mode, store has already the data
		if to_node.is_loading:
			return
		Events.emit_signal("dialogue_to_signal_relation_created", from_node.uuid, to_node.uuid)
		return

	# DIALOGUE -- CHOICE
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.choice:
		wait_for_user_confirmation = _check_node_connection(
			from,
			from_slot,
			Editor.type_to_string(from_node.TYPE),
			to,
			to_slot,
			Editor.type_to_string(to_node.TYPE),
			from_node.right_dialogue_connection,
			from_node.SLOT
		)

		# need user answer
		if wait_for_user_confirmation is GDScriptFunctionState:
			wait_for_user_confirmation = yield(wait_for_user_confirmation, "completed")
		if not wait_for_user_confirmation:
			return

		connect_node(from, from_slot, to, to_slot)
		to_node.values.__editor["parent"] = from_node.uuid

		from_node.right_dialogue_connection = ""
		from_node.right_choices_connection.append(to)

		# in loading mode, store has already the data
		if to_node.is_loading:
			return
		Events.emit_signal("dialogue_to_choice_relation_created", from_node.uuid, to_node.uuid)
		return

	# DIALOGUE -- CONDITIONS
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.condition:
		connect_node(from, from_slot, to, to_slot)
		to_node.values.__editor["parent"] = from_node.uuid
		from_node.right_conditions_connection.append(to)

		# in loading mode, store has already the data
		if to_node.is_loading:
			return
		Events.emit_signal("dialogue_to_condition_relation_created", from_node.uuid, to_node.uuid)
		return

	# CHOICE -- DIALOGUE
	if from_node.TYPE == Editor.Type.choice and to_node.TYPE == Editor.Type.dialogue:
		to_node.left_choices_connection.append(from)
		from_node.values.data.next = to
		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("choice_to_dialogue_relation_created", from_node.uuid, to_node.uuid)
		return

	# CONDITIONS -- DIALOGUE
	if from_node.TYPE == Editor.Type.condition and to_node.TYPE == Editor.Type.dialogue:
		wait_for_user_confirmation = _check_node_connection(
			from,
			from_slot,
			Editor.type_to_string(from_node.TYPE),
			to,
			to_slot,
			Editor.type_to_string(to_node.TYPE),
			from_node.right_dialogue_connection,
			from_node.SLOT
		)

		# need user answer
		if wait_for_user_confirmation is GDScriptFunctionState:
			wait_for_user_confirmation = yield(wait_for_user_confirmation, "completed")
		if not wait_for_user_confirmation:
			return

		to_node.left_condition_connection = from
		from_node.right_dialogue_connection = to
		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("condition_to_dialogue_relation_created", from_node.uuid, to_node.uuid)
		return

	# CONDITIONS -- CHOICES
	if from_node.TYPE == Editor.Type.condition and to_node.TYPE == Editor.Type.choice:
		from_node.right_choice_connection = to
		to_node.left_conditions_connection.append(from)
		to_node.values.__editor["parent"] = from_node.uuid
		to_node.values.data["uuid"] = to
		connect_node(from, from_slot, to, to_slot)
		Events.emit_signal("condition_to_choice_relation_created", from_node.uuid, to_node.uuid)
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
	if not Editor.is_loading:
		FileManager.dirty()
	Events.emit_signal("preview_button_activated")
	var from_node = get_node(from)
	var to_node = get_node(to)

	# remove parent value
	to_node.values.data.erase("parent")

	# ROOT -- DIALOGUE
	if from_node.TYPE == Editor.Type.root and to_node.TYPE == Editor.Type.dialogue:
		Events.emit_signal("root_to_dialogue_relation_deleted")
		from_node.right_dialogue_connection = ""
		to_node.left_dialogues_connection.erase(from)
		disconnect_node(from, from_slot, to, to_slot)
		return

	# ROOT -- CONDITION
	if from_node.TYPE == Editor.Type.root and to_node.TYPE == Editor.Type.condition:
		Events.emit_signal("root_to_condition_relation_deleted", to)

		# clean conditions
		from_node.right_conditions_connection.erase(to)
		if from_node.right_conditions_connection.empty():
			from_node.values.data.erase("conditions")
			from_node.values.__editor.erase("conditions")
		disconnect_node(from, from_slot, to, to_slot)
		return

	# DIALOGUE -- DIALOGUE
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.dialogue:
		from_node.right_dialogue_connection = ""
		to_node.left_dialogues_connection.erase(from)
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_dialogue_relation_deleted", from_node.uuid)
		return

	# DIALOGUE -- CHOICE
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.choice:
		to_node.values.__editor.erase("parent")
		from_node.right_choices_connection.erase(to)
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_choice_relation_deleted", from_node.uuid, to_node.uuid)
		return

	# DIALOGUE -- CONDITION
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.condition:
		to_node.values.__editor.erase("parent")
		from_node.right_conditions_connection.erase(to)
		# right connection
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_condition_relation_deleted", from, to)
		return

	# DIALOGUE -- SIGNAL
	if from_node.TYPE == Editor.Type.dialogue and to_node.TYPE == Editor.Type.signal_node:
		to_node.values.__editor.erase("parent")
		from_node.right_signal_connection = ""
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("dialogue_to_signal_relation_deleted", from)
		return

	# CHOICE -- DIALOGUE
	if from_node.TYPE == Editor.Type.choice and to_node.TYPE == Editor.Type.dialogue:
		to_node.left_choices_connection.erase(from)
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("choice_to_dialogue_relation_deleted", from)
		return

	# CONDITIONS -- DIALOGUE
	if from_node.TYPE == Editor.Type.condition and to_node.TYPE == Editor.Type.dialogue:
		from_node.values.data.next = ""
		from_node.right_dialogue_connection = ""
		to_node.left_condition_connection = ""
		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("condition_to_dialogue_relation_deleted", from)
		return

	# CONDITIONS -- CHOICE
	if from_node.TYPE == Editor.Type.condition and to_node.TYPE == Editor.Type.choice:
		# remove choice from linked dialogue
		from_node.right_choice_connection = ""
		# clear choice
		to_node.left_conditions_connection.erase(from)
		to_node.values.__editor.erase("parent")
		to_node.values.data.erase("uuid")

		disconnect_node(from, from_slot, to, to_slot)
		Events.emit_signal("condition_to_choice_relation_deleted", from, to)
		return


func _on_Graph_node_added(node: GraphNode) -> void:
	node.offset += scroll_offset + NODE_OFFSET
	node.uuid = Uuid.v4()
	_add_Graph_node(node)
	FileManager.dirty()


func _on_Graph_node_loaded(node: GraphNode) -> void:
	node.offset = Vector2(node.values.__editor.offset[0], node.values.__editor.offset[1])
	node.is_loading = true
	_add_Graph_node(node)


func _on_Graph_node_selected(uuid: String) -> void:
	set_selected(get_node(uuid))


func _on_Node_selected(node: Node) -> void:
	Events.emit_signal("toolbox_json_displayed", node.values)


func _on_Preview_predicated_route_displayed(uuid_list: Array) -> void:
	for child in get_children():
		if not child is GraphEditorNode:
			continue
		child.selected = false

	for uuid in uuid_list:
		if not has_node(uuid):
			continue
		get_node(uuid).selected = true


# Check if a relation exist between two nodes.
# If that new relation can be conflicted with the other relations of the node
# e.g. dialogue -> condition and we directly connect a new dialogue
# A message is displayed to disconnect the other relation and create a new one
# @param {String} 	from
# @param {int} 		from_slot
# @param {String} 	from_type
# @param {String} 	to
# @param {int} 		to_slot
# @param {String} 	to_type
# @param {String} 	node_connected	- a node contains his right/next connection if set there a connexion, so a conflict
# @param {int} 	 	node_connected_slot
func _check_node_connection(
	from: String,
	from_slot: int,
	from_type: String,
	to: String,
	to_slot: int,
	to_type: String,
	node_connected: String,
	node_connected_slot: int
) -> bool:
	if node_connected.empty():
		return true

	Events.emit_signal(
		"confirmation_relation_pop_up_displayed",
		(
			"%s has already a relation with an %s node. To you wish to disconnect that relation ?"
			% [from_type, to_type]
		)
	)
	var should_relation_be_deleted = yield(Events, "confirmation_relation_answered")
	if not should_relation_be_deleted:
		return false

	Events.emit_signal(
		"notification_displayed", Editor.Notification.success, "New connection has been created"
	)
	disconnect_node(from, from_slot, node_connected, node_connected_slot)

	return true


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
