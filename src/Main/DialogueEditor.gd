extends Control

const INITIAL_NODE_OFFSET := Vector2(40, 60)
const NODE_OFFSET := Vector2(20, 20)

var node_index := 0

onready var graph_edit := $MarginContainer/VBoxContainer/GraphEdit


func _ready() -> void:
	Events.connect("dialog_node_created", self, "_on_Dialog_node_created")


func _on_Dialog_node_created(node: GraphNode) -> void:
	node.offset += INITIAL_NODE_OFFSET + (node_index * NODE_OFFSET)
	node.uuid = Uuid.v4()
	graph_edit.add_child(node)
	node_index += 1
