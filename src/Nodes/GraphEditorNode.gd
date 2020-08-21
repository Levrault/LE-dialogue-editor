extends GraphNode
class_name GraphEditorNode

var uuid := '' setget set_uuid
var _initial_rect_size := rect_size
var values := {"__editor": {}, "data": {}}
var is_loaded := false

onready var container := $Container


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


func _on_Deleted(value_to_delete: String, field_rect_size: Vector2) -> void:
	values.data.erase(value_to_delete)
	container.rect_size = Vector2(container.rect_size.x, container.rect_size.y - field_rect_size.y)
	rect_size = Vector2(rect_size.x, rect_size.y - (field_rect_size.y * 2))


func _on_Close_request() -> void:
	if values["__editor"].has("parent"):
		Events.emit_signal("node_deleted", values["__editor"].parent, 0, uuid, 0)
	queue_free()
