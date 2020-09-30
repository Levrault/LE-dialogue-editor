# Root node are already added to the scene and are unique in the graph
# Can only have one starting node
# - Can connect to one dialogue node
# - Can connect to multiple conditions
extends GraphEditorNode

const TYPE = Editor.Type.root
const SLOT = 0

var right_dialogue_connection := ""
var right_conditions_connection := []


func _ready() -> void:
	if not is_loading:
		values = {"__editor": {"uuid": 'root', "offset": [offset.x, offset.y]}, "data": {}}
	uuid = "root"
	Store.json_raw["root"] = values.data
	Store.root_node = self
