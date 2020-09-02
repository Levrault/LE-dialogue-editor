extends RichTextLabel

var _total_scroll_time := 0.0

onready var _timer: Timer = $Timer
onready var _scroll_timer: Timer = $Scroll
onready var _delay: Timer = $Delay


func _ready() -> void:
	Events.connect("dialogue_animation_skipped", self, "_on_Skip_animation")
	_timer.connect("timeout", self, "_on_Text_animation")
	_scroll_timer.connect("timeout", self, "_on_Scroll_animation")
	_delay.connect("timeout", _scroll_timer, "start")


# stop/start animation
# param {bool} value
func toggle_animation(value: bool) -> void:
	if not value:
		_timer.stop()
		_delay.stop()
		_scroll_timer.stop()
		return

	get_v_scroll().value = 0
	visible_characters = 0
	_timer.start()
	_delay.start()


# Show a new letter at each call
func _on_Text_animation() -> void:
	if visible_characters == text.length():
		_on_Skip_animation()
		return
	visible_characters += 1


# The player decide to skip the animation
func _on_Skip_animation() -> void:
	_timer.stop()
	_delay.stop()
	_scroll_timer.stop()
	visible_characters = get_total_character_count()
	get_v_scroll().value = get_v_scroll().max_value
	owner.next_action()


func _on_Scroll_animation() -> void:
	get_v_scroll().value += 1
