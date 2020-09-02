# Main controlled character
class_name Player
extends Actor

const FLOOR_NORMAL := Vector2.UP
const SNAP := Vector2(0, 10)

var is_active := true setget set_is_active
var is_handling_input := true setget set_is_handling_input

onready var state_machine: StateMachine = $StateMachine
onready var skin: Node2D = $Skin
onready var collider: CollisionShape2D = $CollisionShape2D


func set_is_handling_input(value: bool) -> void:
	$StateMachine.set_process_unhandled_input(value)
	is_handling_input = value


func set_is_active(value: bool) -> void:
	is_active = value
	if not collider:
		return
	collider.disabled = not value


func horizontal_mirror(direction: float) -> void:
	if direction == 0:
		return
	skin.scale.x = sign(direction)
