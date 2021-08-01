extends HBoxContainer

var in_error := false

onready var counter := $Counter
onready var dash := $Dash
onready var limit := $Limit


func _ready() -> void:
	yield(owner, "ready")
	assert (owner.locale != null)

	owner.locale.connect("text_changed", self, "_on_Text_changed")

	if Config.values.configuration.dialogue_character_limit == 0:
		dash.queue_free()
		limit.queue_free()
		return
	limit.text = "%s" % Config.values.configuration.dialogue_character_limit


func _on_Text_changed() -> void:
	var locale_length = owner.locale.text.length()
	counter.text = "%s" % locale_length
	
	if Config.values.configuration.dialogue_character_limit == 0:
		return

	if in_error:
		if locale_length <= Config.values.configuration.dialogue_character_limit:
			_success()
		return

	if locale_length > Config.values.configuration.dialogue_character_limit:
		_error()



func _error() -> void:
	in_error = true
	$Tween.interpolate_property(
		self, "modulate", modulate, Color("d32f2f"), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN
	)
	$Tween.start()


func _success() -> void:
	in_error = false
	$Tween.interpolate_property(
		self, "modulate", modulate, Color(1,1,1), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN
	)
	$Tween.start()
