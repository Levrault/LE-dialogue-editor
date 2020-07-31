extends GraphNode


func _ready() -> void:
	connect("close_request", self, "_on_Close_request")
	connect("resize_request", self, "_on_Resize_request")

	set_slot(0, true, 0, Color(1, 1, 1, 1), true, 0, Color(1, 1, 1, 1))


func _on_Close_request() -> void:
	queue_free()


func _on_Resize_request(new_minsize: Vector2) -> void:
	rect_size = new_minsize
