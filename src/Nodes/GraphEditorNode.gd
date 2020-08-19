extends GraphNode
class_name GraphEditorNode

var uuid := '' setget set_uuid
var _initial_rect_size := rect_size
var values := {"__editor": {}, "data": {}}
var is_loaded := false


func _ready() -> void:
	connect("close_request", self, "_on_Close_request")
	connect("offset_changed", self, "_on_Offset_changed")

	if not is_loaded:
		values["__editor"]["uuid"] = uuid
		values["__editor"]["offset"] = [offset.x, offset.y]


func set_uuid(id: String) -> void:
	uuid = id
	title += id


func _on_Offset_changed() -> void:
	values["__editor"]["offset"] = [offset.x, offset.y]


func _on_Close_request() -> void:
	queue_free()
