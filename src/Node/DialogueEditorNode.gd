extends GraphNode
class_name DialogueEditorNode

const SIZE_CONTAINER_BOTTOM_MARGIN := 50
const COLLAPSED_SIZE := Vector2(346, 20)

var uuid := '' setget set_uuid

var _is_collapsed := false
var _initial_rect_size := rect_size


func _ready() -> void:
	connect("close_request", self, "_on_Close_request")
	connect("resize_request", self, "_on_Resize_request")

func set_uuid(id : String) -> void:
	uuid = id
	title += id


func _on_Close_request() -> void:
	queue_free()
