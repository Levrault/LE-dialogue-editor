extends State

onready var move := get_parent()
onready var jump_input_buffering: Timer = $JumpInputBuffering


func physics_process(delta: float) -> void:
	if owner.is_handling_input and owner.is_on_floor() and move.get_move_direction().x != 0.0:
		_state_machine.transition_to("Move/Run")
	elif not owner.is_on_floor():
		_state_machine.transition_to("Move/Air", {coyote_time = true})


func enter(msg: Dictionary = {}) -> void:
	_parent.enter(msg)
	_parent.velocity = Vector2.ZERO

	if not jump_input_buffering.is_stopped():
		_state_machine.transition_to("Move/Air", {impulse = true})
		jump_input_buffering.stop()
		return


func exit() -> void:
	_parent.exit()
