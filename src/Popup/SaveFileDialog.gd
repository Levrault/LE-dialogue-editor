extends FileDialog


func _ready():
	connect("confirmed", self, "_on_Confirmed")


func _on_Confirmed() -> void:
	print_debug("json will be save inside %s" % current_path)
	Serialize.save(current_path)
