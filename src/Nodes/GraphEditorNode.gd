extends GraphNode
class_name GraphEditorNode

var uuid := '' setget set_uuid
var _initial_rect_size := rect_size


func _ready() -> void:
	connect("close_request", self, "_on_Close_request")


func set_uuid(id: String) -> void:
	uuid = id
	title += id


func _on_Close_request() -> void:
	# TODO: delete all relations
	queue_free()
