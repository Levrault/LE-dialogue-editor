# Detect NPC and manage interactions the player can 
# have with them
extends Area2D

enum States { idle, pending, continuing, choosing, ending }

var _npc: Npc = null
var _state = States.idle


# Init detect zone and linh change state to the dialogueBox
func _ready() -> void:
	Events.connect("dialogue_last_text_displayed", self, "_on_State_changed", [States.ending])
	Events.connect("dialogue_text_displayed", self, "_on_State_changed", [States.continuing])
	Events.connect("dialogue_choices_displayed", self, "_on_State_changed", [States.choosing])
	Events.connect("dialogue_choices_pressed", self, "_on_State_changed", [States.pending])
	Events.connect("dialogue_timed_out", self, "_on_State_changed", [States.pending])
	connect("body_entered", self, "_on_Npc_entered")
	connect("body_exited", self, "_on_Npc_exited")
	set_process_unhandled_input(false)


# Start, skip, end dialogue
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction"):
		_interact()
		return
	# allow jump to display next when dialogue is enable
	if not _state == States.idle and event.is_action_pressed("jump"):
		_interact()
		return


# Is possible to interact with the npc
# @param {Npc} body
func _on_Npc_entered(body: Npc) -> void:
	set_process_unhandled_input(true)
	_npc = body
	_npc.is_interactable = true

	if _npc.is_auto_trigger:
		_interact()


# Is no longer possible to interact with the npc
# @param {Npc} body
func _on_Npc_exited(body: Npc) -> void:
	body.is_interactable = false
	set_process_unhandled_input(false)
	_npc = null


# Change Npc's interaction state
# @param {int} value - should be valid State's enum value
func _on_State_changed(value: int) -> void:
	_state = value


func _interact() -> void:
	# last dialogue/interaction was displayed, end the interaction
	if _state == States.ending:
		owner.is_handling_input = true
		_npc.is_in_interaction = false
		_state = States.pending
		_state = States.idle
		Events.emit_signal("dialogue_finished")
		return

	# interaction with npc has begun
	if not _npc.is_in_interaction:
		owner.is_handling_input = false
		_npc.is_in_interaction = true
		_state = States.pending
		return

	if _state == States.continuing:
		_npc.next_interaction()
		_state = States.pending
		return

	if _state == States.choosing:
		return

	# call next interaction
	Events.emit_signal("dialogue_animation_skipped")
