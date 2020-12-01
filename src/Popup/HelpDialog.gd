extends AcceptDialog


func _ready() -> void:
	Events.connect("about_pop_up_displayed", self, "popup")
	$MarginContainer/Help/Version/Text.text = ProjectSettings.get_setting("Info/version")
	$MarginContainer/Help/License/Text.text = ProjectSettings.get_setting("Info/license")
	$MarginContainer/Help/Creator/Text.text = ProjectSettings.get_setting("Info/creator")
