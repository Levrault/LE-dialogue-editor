extends Node


func save(path: String) -> void:
	var file = File.new()
	file.open("%s.json" % path, File.WRITE)
	file.store_string(Json.to_string())
	file.close()


func load(path: String):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content
