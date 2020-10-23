# Root node are already added to the scene and are unique in the graph
# Can only have one starting node
# - Can connect to one dialogue node
# - Can connect to multiple conditions
#
# generated json
# linear 
#   "root": { "next": "e7c3a4cf-4b63-4149-94eb-d396f8f4f9fe" },
#
# Conditional
#   "root": {
#     "conditions": [
#       { "next": "db401685-3241-4a2f-8ccd-b526047aa621" },
#       {
#         "has_kill_dragon": {
#           "value": false,
#           "operator": "equal",
#           "type": "boolean"
#         },
#         "next": "f38278b3-cb69-430e-84b8-4f23bcdf7adc"
#       }
#     ]
#   },

extends GraphEditorNode

const TYPE = Editor.Type.root
const SLOT = 0

var right_dialogue_connection := ""
var right_conditions_connection := []


func _ready() -> void:
	if not is_loading:
		values = {"__editor": {"uuid": 'root', "offset": [offset.x, offset.y]}, "data": {}}
	uuid = "root"
	Store.json["root"] = values.data
	Store.root_node = self
