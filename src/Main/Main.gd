extends Control

const INITIAL_NODE_OFFSET := Vector2(40, 60)
const NODE_OFFSET := Vector2(20, 20)

var node_index := 0

onready var graph_edit := $MarginContainer/VBoxContainer/GraphEdit


func _ready() -> void:
	Events.connect("graph_node_added", self, "_on_graph_node_added")
	Events.connect("menu_popup_displayed", self, "_on_Menu_popup_displayed")


func _on_graph_node_added(node: GraphNode) -> void:
	node.offset += INITIAL_NODE_OFFSET + (node_index * NODE_OFFSET)
	node.uuid = Uuid.v4()
	graph_edit.add_child(node)
	node_index += 1

	# generate signal to add a new entry inside the json
	if node.TYPE == Editor.Type.choice:
		Events.emit_signal("choice_node_created", {uuid = node.uuid, values = node.values})
		return

	if node.TYPE == Editor.Type.condition:
		Events.emit_signal("condition_node_created", {uuid = node.uuid, values = node.values})
		return

	Events.emit_signal("dialogue_node_created", {uuid = node.uuid, values = node.values})


func _on_Menu_popup_displayed(name: String) -> void:
	assert(has_node(name))
	get_node(name).popup()
