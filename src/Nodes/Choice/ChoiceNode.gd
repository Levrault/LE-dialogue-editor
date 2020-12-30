# Choices are multiple answer/choice/selectables potionhs that the player can choose.
# They can be conditionned, like a certain choice won't be available if conditions aren't met.
# Conditions should prevent to duplicate multiple dialogue and made a more readable tree. When
# a condition is set, a conditions array is pointing to the choice uuid. 
#
# Generated json
#   "choices": [
#     { 
#       "text": { 
#		  "uuid": "choice uuid"
#         "en": "c1", 
#         "fr": "" 
#       }, 
#       "next": "" 
#     },
#     { "text": { "en": "c2", "fr": "" }, "next": "" }
#   ],
#   "conditions": [
#     {
#       "has_meet": { "value": true, "operator": "equal", "type": "boolean" },
#       "next": "choice uuid"
#     }
#   ],
extends GraphEditorNode

const TYPE = Editor.Type.choice
var left_conditions_connection := []


func _ready() -> void:
	if not is_loading:
		values = {
			"__editor": {"uuid": uuid, "offset": [offset.x, offset.y]},
			"data": {"text": {"en": "", "fr": ""}, "next": ""}
		}


func on_Close_request() -> void:
	.on_Close_request()
	for condition_uuid in left_conditions_connection.duplicate():
		Events.emit_signal("node_deleted", condition_uuid, 0, uuid, 0)
	Store.choices_node.erase(uuid)
