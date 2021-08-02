extends WindowDialog

var graph_node_owner = null
var locale_field_owner = null
onready var text_edit := $MarginContainer/TextEdit


func _ready() -> void:
	Events.connect("expand_text_dialogued_opened", self, "_on_Expand_text_dialogued_opened")
	text_edit.connect("text_changed", self, "_on_Text_changed")


func _on_Expand_text_dialogued_opened(field_owner) -> void:
	graph_node_owner = field_owner.owner
	locale_field_owner = field_owner
	window_title = graph_node_owner.uuid
	text_edit.text = graph_node_owner.values.data.text[Editor.locale]
	popup()


func _on_Text_changed() -> void:
	graph_node_owner.values.data.text[Editor.locale] = text_edit.text
	locale_field_owner.locale.text = text_edit.text
	locale_field_owner.locale.emit_signal("text_changed")
