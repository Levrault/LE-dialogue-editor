# Stats for the player or the monsters, to manage health, etc.
# Attach an instance of Stats to any object to give it health and stats.
class_name Stats
extends Node2D

signal health_changed(old_value, new_value)
signal health_depleted
signal damage_taken

export var max_health := 1.0 setget set_max_health
export var attack: int = 1

var modifiers := {}
var invulnerable := false
var health := max_health


func _ready() -> void:
	health = max_health


# Has take a hit
# @param {Hit} hit
func take_damage(hit: Hit) -> void:
	print("take damage")
	if invulnerable:
		return

	print_debug("%s has taken damage of : %x" % [owner.get_name(), hit.damage])

	if hit.is_instakill:
		emit_signal("health_depleted")
		return

	var old_health = health
	health -= hit.damage
	emit_signal("damage_taken")
	health = max(0, health)
	emit_signal("health_changed", health, old_health)
	if health == 0:
		emit_signal("health_depleted")


# Healing
# @param {float} amount
func heal(amount: float) -> void:
	var old_health = health
	health = min(health + amount, max_health)
	emit_signal("health_changed", health, old_health)


# setter for max_health
# @param {float} value
func set_max_health(value: float) -> void:
	if value == null:
		return
	max_health = max(1, value)


# SAdd status effect e.g. poison
# @param {int} id
# @param {any} modifier - class, object...
func add_modifier(id: int, modifier) -> void:
	modifiers[id] = modifier


# Remove effect e.g. poison
# @param {int} id
func remove_modifier(id: int) -> void:
	modifiers.erase(id)


# Invulnerable frame
# @param {float} time
func set_invulnerable_for_seconds(time: float) -> void:
	invulnerable = true

	var timer := get_tree().create_timer(time)
	yield(timer, "timeout")

	invulnerable = false
