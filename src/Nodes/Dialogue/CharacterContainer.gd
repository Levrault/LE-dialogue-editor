extends HBoxContainer


func _ready() -> void:
	yield(owner, "ready")
	if not Config.values.configuration.has_name and not Config.values.configuration.has_portrait:
		owner.values.data.erase("name")
		owner.values.data.erase("portrait")
		queue_free()
		return


	if not Config.values.configuration.has_portrait:
		owner.values.data.erase("portrait")
		$PortraitPreview.queue_free()
		$PortraitPlaceholder.queue_free()
		$FieldsContainer/PortraitContainer.queue_free()
		return
