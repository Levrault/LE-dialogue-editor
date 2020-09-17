extends VBoxContainer

var conditions := {}
onready var conditions_container := $ConditionsContainer
onready var title := $Title


func fold() -> void:
	pass


func unfold() -> void:
	pass


func _on_Condition_checked(name: String, value: bool) -> void:
	if not value and conditions.has(name):
		conditions.erase(name)
		return
	conditions[name] = true


