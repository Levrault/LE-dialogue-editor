extends WindowDialog


func _ready() -> void:
	Events.connect("preview_dialog_opened", self, "_on_Dialog_opened")


func _on_Dialog_opened() -> void:
	if Store.json_raw.empty() or Store.dialogues_node.empty():
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.warning,
			"A preview can't be done with an empty dialogue tree"
		)
		return
	var preview = load("res://src/Preview/Preview.tscn").instance()
	$Container.add_child(preview)
	preview.position = Vector2(-250, 0)
	# yield(preview, "ready")
	popup()
