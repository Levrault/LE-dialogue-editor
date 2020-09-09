extends Button

var message := "" setget set_message

onready var rich_text_label := $MarginContainer/RichTextLabel
onready var margin_container := $MarginContainer
onready var tween = $Tween


func _ready() -> void:
	modulate = Color(1, 1, 1, 0)


func set_message(new_message: String) -> void:
	message = new_message
	rich_text_label.text = new_message


func resize() -> void:
	rect_min_size = margin_container.rect_size
	pop_in_animation()


func pop_in_animation() -> void:
	tween.interpolate_property(
		self, "modulate", modulate, Color(1, 1, 1, 1), .25, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR
	)
	tween.start()
