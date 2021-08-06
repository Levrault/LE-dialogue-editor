extends HBoxContainer


func _ready():
	if not Config.values.configuration.has_portrait:
		hide()
