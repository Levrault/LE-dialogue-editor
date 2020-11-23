# Dialogue node
# Left connection rules
#  * Multiples DIALOGUE can have point to a single DIALOGUE (Many to One relationship)
#  * Only one conditions node can be connected to a Dialogue (One To One relationship)
#  * A choice is related to one dialogue (One to One relationship)
# Right connection rules
#  * DIALOGUE can only have an one to one connection to another DIALOGUE (One to One relationship)
#  * One right connection with SIGNALS (One To One relationship)
#  * A dialogue can only be connected to one conditions node (One To One relationship)
#  * Can have multiples choices (One to Many relationship)
#
# Generated json
# Case linear
#   "e26a5ccf-66fe-4319-a130-47652e1a63b4": {
#     "name": "Hero",
#     "portrait": "res://assets/examples/hero.png",
#     "text": { "en": "This is the default response", "fr": "" },
#	  "next": "79b93840-045d-4df1-b03a-52e984e0b2c2"
#   },
# Case Conditional linear
#   "e26a5ccf-66fe-4319-a130-47652e1a63b4": {
#     "name": "Hero",
#     "portrait": "res://assets/examples/hero.png",
#     "text": { "en": "This is the default response", "fr": "" },
#     "conditions": [
#       {
#         "has_kill_dragon": {
#           "value": true,
#           "operator": "equal",
#           "type": "boolean"
#         },
#         "next": "0efd2476-c3f1-4d85-96b6-dfc1be38f0d0"
#       }
#     ]
#   },
#
# Case Choices
#   "e26a5ccf-66fe-4319-a130-47652e1a63b4": {
#     "name": "Hero",
#     "portrait": "res://assets/examples/hero.png",
#     "text": { "en": "This is the default response", "fr": "" },
#     "choices": [
#       {
#         "text": { "en": "choice 1", "fr": "" },
#         "next": "02517b8f-7def-4309-bef3-6231a201c232"
#       },
#       {
#         "text": { "en": "choice 2", "fr": "" },
#         "next": "72431c16-1816-4836-b957-d82e792db206"
#       }
#     ]
#   },
#
# Case Conditional choices. Node needs to have conditions AND choices params
#   "e26a5ccf-66fe-4319-a130-47652e1a63b4": {
#     "name": "Hero",
#     "portrait": "res://assets/examples/hero.png",
#     "text": { "en": "This is the default response", "fr": "" },
#     "conditions": [
#       { "next": "fd6200dc-6623-4e20-96a0-61ba6632be15" },
#      ],
#     "choices": [
#       {
#         "text": { "en": "choice 1", "fr": "" },
#         "next": "02517b8f-7def-4309-bef3-6231a201c232"
#       },
#       {
#         "text": { "en": "choice 2", "fr": "" },
#         "next": "72431c16-1816-4836-b957-d82e792db206"
#       }
#     ]
#   },
extends GraphEditorNode

const TYPE = Editor.Type.dialogue
const SLOT := 0

# Dialogues
var left_dialogues_connection := []
var right_dialogue_connection := ""

# Conditions
var left_condition_connection := ""
var right_conditions_connection := []

# Choices
var left_choices_connection := []
var right_choices_connection := []

# Signal
var right_signal_connection := ""

onready var character_name_option := $Container/Character/FieldsContainer/CharacterNameContainer/CharacterNameOptions
onready var portrait_preview := $Container/Character/PortraitPreview


func _ready() -> void:
	if not is_loading:
		values = {
			"__editor": {"uuid": uuid, "offset": [offset.x, offset.y]},
			"data": {"name": "", "portrait": "", "text": {"en": "", "fr": ""}}
		}


func on_Close_request() -> void:
	# left connection, remove CHOICES - DIALOGUE relation
	# prevent array to clean itself with node_deleted signal and stop cleaning all the relation
	for choice_uuid in left_choices_connection.duplicate():
		Events.emit_signal("node_deleted", choice_uuid, 0, uuid, 0)

	# left connection, remove DIALOGUE - DIALOGUE
	for dialogue_uuid in left_dialogues_connection.duplicate():
		Events.emit_signal("node_deleted", dialogue_uuid, 0, uuid, 0)

	# left connection: remove CONDITIONS
	if not left_condition_connection.empty():
		Events.emit_signal("node_deleted", left_condition_connection, 0, uuid, 0)

	# right connection : remove CONDITIONS
	for condition in right_conditions_connection.duplicate():
		Events.emit_signal("node_deleted", uuid, 0, condition, SLOT)

	# right connection: remove CHOICES
	for choice in right_choices_connection.duplicate():
		Events.emit_signal("node_deleted", uuid, 0, choice, SLOT)

	# right connection : remove SIGNALs
	if not right_signal_connection.empty():
		Events.emit_signal("node_deleted", uuid, 0, right_signal_connection, SLOT)
		right_signal_connection = ""

	.on_Close_request()
	Store.dialogues_node.erase(uuid)
	Store.json.erase(uuid)
