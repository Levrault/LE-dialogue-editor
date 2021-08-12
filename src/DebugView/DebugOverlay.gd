extends Panel


func _ready():
	Events.connect("debug_json_displayed", self, "_on_Debug_json_displayed")


func _on_Debug_json_displayed(values: Dictionary) -> void:
	$MarginContainer/Json.text = JSON.print(values, "\t")
