extends GraphNode

const SIZE_CONTAINER_BOTTOM_MARGIN := 50

onready var container := $Container

func _ready() -> void:
	connect("close_request", self, "_on_Close_request")
	connect("resize_request", self, "_on_Resize_request")


func _on_Close_request() -> void:
	queue_free()


func _on_Resize_request(new_minsize: Vector2) -> void:
	rect_size = new_minsize
	container.rect_size = new_minsize - Vector2(0, SIZE_CONTAINER_BOTTOM_MARGIN)

