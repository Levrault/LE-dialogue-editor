extends State

signal jumped

export var acceleration_x := 5000.0
export var min_jump_impulse := 450.0
export var jump_impulse := 1500.0
export var max_jump_count := 1

var _jump_count := 1

onready var _coyote_time: Timer = $CoyoteTime


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		emit_signal("jumped")
		if _jump_count < max_jump_count:
			jump()
		elif _coyote_time.time_left > 0.0:
			_coyote_time.stop()
			jump()
	if (
		event.is_action_released("jump")
		and abs(_parent.velocity.y) > min_jump_impulse
		and not _parent.velocity.y > 0
	):
		_parent.velocity.y = -min_jump_impulse

	_parent.unhandled_input(event)


func physics_process(delta: float) -> void:
	_parent.physics_process(delta)

	# Landing
	if owner.is_on_floor():
		owner.is_snapped_to_floor = true
		var target_state := "Move/Idle" if _parent.get_move_direction().x == 0 else "Move/Run"
		_state_machine.transition_to(target_state, {contact = true})


func enter(msg: Dictionary = {}) -> void:
	_parent.enter(msg)
	_parent.acceleration.x = acceleration_x
	owner.is_snapped_to_floor = false

	if "coyote_time" in msg:
		_coyote_time.start()
	if "impulse" in msg:
		jump()


func exit() -> void:
	_jump_count = 0
	_parent.acceleration = _parent.acceleration_default
	_parent.exit()


func jump() -> void:
	owner.skin.play("jump")
	_parent.velocity.y = 0
	_parent.velocity += calculate_jump_velocity(jump_impulse)
	_jump_count += 1


# Returns a new velocity with a vertical impulse applied to it
func calculate_jump_velocity(impulse: float = 0.0) -> Vector2:
	return _parent.calculate_velocity(  # replace delta
		_parent.velocity, _parent.max_speed, Vector2(0.0, impulse), Vector2.ZERO, 1.0, Vector2.UP
	)
