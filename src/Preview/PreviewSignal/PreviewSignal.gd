extends MarginContainer

var preview_signal_label_scene = preload("res://src/Preview/PreviewSignal/PreviewSignalLabel.tscn")
var values := {} setget set_values

onready var list_container := $Wrapper/Container/MarginContainer/ListContainer
onready var wrapper := $Wrapper


func set_values(new_values: Dictionary) -> void:
	values = new_values

	for child in list_container.get_children():
		child.queue_free()

	for key in values:
		var preview_signal_label = preview_signal_label_scene.instance()
		list_container.add_child(preview_signal_label)
		preview_signal_label.text = "- %s %s" % [key, values[key]]

	wrapper.call_deferred("pop_in_animation")
