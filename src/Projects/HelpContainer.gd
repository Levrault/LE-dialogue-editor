extends VBoxContainer


func _ready() -> void:
	$Wiki.connect("pressed", self, "_on_Browser_action_pressed", ["https://github.com/Levrault/levrault-dialogue-editor/wiki"])
	$Github.connect("pressed", self, "_on_Browser_action_pressed", ["https://github.com/Levrault/levrault-dialogue-editor"])
	$Twitter.connect("pressed", self, "_on_Browser_action_pressed", ["https://twitter.com/LFLangis"])
	

func  _on_Browser_action_pressed(url: String) -> void:
	OS.shell_open(url)
