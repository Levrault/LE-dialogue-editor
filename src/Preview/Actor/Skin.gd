# Should manage all the sprite/animation of an Actor
# Create to be controller by the owner
extends Node2D

signal animation_finished(anim_name)

onready var anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	anim.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")


func play(anim_name: String) -> void:
	assert(anim_name in anim.get_animation_list())
	anim.play(anim_name)


# Gate to let the owner and the skin node communicate
# @param {String} anim_name
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished", anim_name)
