extends CenterContainer


func _ready():
	Events.connect("spinner_displayed", self, "show")
	Events.connect("spinner_hidden", self, "hide")
