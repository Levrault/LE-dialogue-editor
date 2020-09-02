# State interface to use in Hierarchical State machines
# The lowest leaf tries to handle callbacks and if it can'it, it delegates the work to its parent.
class_name State, "res://assets/icons/state.svg"
extends Node

onready var _state_machine := _get_state_machine(self)

var _parent: State = null


func _ready() -> void:
	yield(owner, "ready")
	_parent = get_parent() as State


func unhandled_input(event: InputEvent) -> void:
	pass


func physics_process(delta: float) -> void:
	pass


func enter(msg: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass


func _get_state_machine(node: Node) -> Node:
	if node != null and not node.is_in_group("state_machine"):
		return _get_state_machine(node.get_parent())
	return node
