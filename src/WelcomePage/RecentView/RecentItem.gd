extends HBoxContainer

onready var button := $AnimatedToolButton


func set_item(workspace: Dictionary) -> void:
	$AnimatedToolButton.text = workspace.folder
	if not workspace.has_portrait:
		$Portrait.queue_free()
	if not workspace.has_name:
		$Name.queue_free()
