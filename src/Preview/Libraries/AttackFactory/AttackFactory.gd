class_name AttackFactory, "res://assets/icons/attack_factory.svg"
extends Node2D

var _is_attacking := false

onready var damage_source: DamageSource = $DamageSource as DamageSource


func _ready() -> void:
	yield(owner, "ready")


func create(attack_name: String) -> void:
	if _is_attacking:
		return
	_is_attacking = true
	owner.skin.play(attack_name)
	owner.skin.connect("animation_finished", self, "_on_Skin_animation_finished")


func _on_Skin_animation_finished(anim_name: String) -> void:
	_is_attacking = false
	damage_source.set_active(false)
	owner.skin.disconnect("animation_finished", self, "_on_Skin_animation_finished")
