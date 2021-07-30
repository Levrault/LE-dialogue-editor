extends VBoxContainer


func _ready() -> void:
	$Wiki.connect(
		"pressed", self, "_on_Browser_action_pressed", [ProjectSettings.get_setting("Info/wiki")]
	)
	$Github.connect(
		"pressed", self, "_on_Browser_action_pressed", [ProjectSettings.get_setting("Info/github")]
	)
	$Twitter.connect(
		"pressed", self, "_on_Browser_action_pressed", [ProjectSettings.get_setting("Info/twitter")]
	)


func _on_Browser_action_pressed(url: String) -> void:
	OS.shell_open(url)
