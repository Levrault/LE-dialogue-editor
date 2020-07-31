extends GraphEdit


func _ready() -> void:
	connect("connection_request", self, "_on_Connection_request")


func _on_Connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	connect_node(from, from_slot, to, to_slot)
