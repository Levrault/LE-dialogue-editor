extends State

const PASS_TROUGHT_LAYER := 2

export var max_speed_default := Vector2(500.0, 1500.00)
export var acceleration_default := Vector2(10000, 3000.0)
export var decceleration_default := Vector2(10000, 3000.0)
export var max_speed_fall := 1500.00

var acceleration := acceleration_default
var decceleration := decceleration_default
var max_speed := max_speed_default
var velocity := Vector2.ZERO

var _is_move_down_key_pressed := false

static func get_move_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 1.0
	)

static func calculate_velocity(
	old_velocity: Vector2,
	max_speed: Vector2,
	acceleration: Vector2,
	decceleration: Vector2,
	delta: float,
	move_direction: Vector2,
	max_speed_fall := 1500.00
) -> Vector2:
	var new_velocity := old_velocity
	new_velocity.y += move_direction.y * acceleration.y * delta

	if move_direction.x:
		new_velocity.x += move_direction.x * acceleration.x * delta
	elif abs(new_velocity.x) > 0.1:
		new_velocity.x -= decceleration.x * delta * sign(new_velocity.x)
		new_velocity.x = new_velocity.x if sign(new_velocity.x) == sign(old_velocity.x) else 0.0

	new_velocity.x = clamp(new_velocity.x, -max_speed.x, max_speed.x)
	new_velocity.y = clamp(new_velocity.y, -max_speed.y, max_speed_fall)

	return new_velocity


func unhandled_input(event: InputEvent) -> void:
	if owner.is_on_floor():
		if not _is_move_down_key_pressed and event.is_action_pressed("jump"):
			_state_machine.transition_to("Move/Air", {impulse = true})
			return
		if _is_move_down_key_pressed and event.is_action_pressed("jump"):
			owner.set_collision_mask_bit(PASS_TROUGHT_LAYER, false)
			_state_machine.transition_to("Move/Air")
			return

	if event.is_action_pressed("move_down"):
		_is_move_down_key_pressed = true
		return
	if event.is_action_released("move_down"):
		_is_move_down_key_pressed = false
		return


func physics_process(delta: float) -> void:
	var direction := get_move_direction()

	if not owner.is_handling_input:
		direction.x = 0

	velocity = calculate_velocity(
		velocity, max_speed, acceleration, decceleration, delta, direction
	)
	if owner.is_snapped_to_floor:
		velocity = owner.move_and_slide_with_snap(velocity, owner.SNAP, owner.FLOOR_NORMAL, true)
	else:
		velocity = owner.move_and_slide(velocity, owner.FLOOR_NORMAL)

	if direction.x != 0:
		owner.horizontal_mirror(direction.x)


func enter(msg: Dictionary = {}) -> void:
	if "contact" in msg:
		owner.skin.play("contact")
	$Air.connect("jumped", $Idle.jump_input_buffering, "start")


func exit() -> void:
	$Air.disconnect("jumped", $Idle.jump_input_buffering, "start")
