extends VBoxContainer

var button := preload("res://src/Components/AnimatedToolButton.tscn")


func _ready() -> void:
	Events.connect("projects_list_changed", self, "_on_Projects_list_changed")
	_on_Projects_list_changed()


func _on_Projects_list_changed() -> void:
	for child in get_children():
		child.queue_free()

	for project in Config.globals.projects.list:
		var project_button := button.instance()
		add_child(project_button)
		project_button.align = Button.ALIGN_LEFT
		project_button.text = project.project
		project_button.connect("pressed", self, "_on_Pressed", [project])


func _on_Pressed(project: Dictionary) -> void:
	Config.load_file(project.project)
	Editor.project = project
	get_tree().change_scene("res://src/Main/Main.tscn")
