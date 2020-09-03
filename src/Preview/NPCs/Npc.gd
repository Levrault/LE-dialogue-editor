# Non playable character
class_name Npc
extends KinematicBody2D

export var conditions := {}
export var is_auto_trigger := false

var is_interactable := false setget set_is_interactable
var is_in_interaction := false setget set_is_in_interaction

onready var dialogue_controller: DialogueController = $DialogueController as DialogueController


# Setter
# When player can do an interaction with the NPC
# @param {bool} value
func set_is_interactable(value: bool) -> void:
	is_interactable = value
	$Talk.visible = value


# Setter
# When the NPC is interacting with the player
# @param {bool} value
func set_is_in_interaction(value: bool) -> void:
	is_in_interaction = value
	if value:
		dialogue_controller.load()
		dialogue_controller.start()
	else:
		dialogue_controller.clear()


# When the NPC is interacting with the player
# @param {bool} value
func next_interaction() -> void:
	dialogue_controller.next()


# Is used when the npc is displayed on a cinematic
func cinematic_close_dialogue() -> void:
	self.is_in_interaction = false
	Events.emit_signal("dialogue_finished")
