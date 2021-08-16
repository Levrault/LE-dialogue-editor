extends RichTextLabel


func _ready():
	Events.connect("toolbox_json_displayed", self, "_on_Json_displayed")


func _on_Json_displayed(values: Dictionary) -> void:
	text = JSON.print(values, "\t")
