extends PanelContainer

var message := "" setget set_message

onready var rich_text_label := $MarginContainer/RichTextLabel
onready var margin_container := $MarginContainer
onready var tween = $Tween


func _ready() -> void:
	modulate = Color(1, 1, 1, 0)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.is_action_pressed("left_click"):
			Events.emit_signal("graph_node_focused", owner.name)


func set_message(new_message: String) -> void:
	message = new_message
	rich_text_label.text = new_message


func pop_in_animation() -> void:
	tween.interpolate_property(
		self, "modulate", modulate, Color(1, 1, 1, 1), .25, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR
	)
	tween.start()
