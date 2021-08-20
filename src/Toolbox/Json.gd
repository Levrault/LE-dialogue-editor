extends RichTextLabel

var values: Dictionary = {}


func _ready():
	Events.connect("toolbox_json_displayed", self, "_on_Json_displayed")


func _process(delta):
	text = JSON.print(values, "\t")


func _on_Json_displayed(node_values: Dictionary) -> void:
	values = node_values
