extends VBoxContainer

const FOLD_TIME := .075

var conditions := {}
onready var conditions_container := $ConditionsContainer
onready var fold_button := $HBoxContainer/Fold
onready var unfold_button := $HBoxContainer/UnFold
onready var title := $Title
onready var tween := $Tween


func reset_fold_button() -> void:
	fold_button.show()
	unfold_button.hide()


func fold() -> void:
	title.hide()
	fold_button.hide()
	unfold_button.show()

	var delay := FOLD_TIME / conditions_container.get_child_count()
	var conditions_children := conditions_container.get_children()
	conditions_children.invert()
	for i in range(0, conditions_container.get_child_count()):
		tween.interpolate_deferred_callback(conditions_children[i], FOLD_TIME - (i * delay), "hide")
		tween.start()


func unfold() -> void:
	title.show()
	fold_button.show()
	unfold_button.hide()

	var delay := FOLD_TIME / conditions_container.get_child_count()
	var conditions_children := conditions_container.get_children()
	conditions_children.invert()

	for i in range(0, conditions_container.get_child_count()):
		var child = conditions_children[i]
		# manage empty label
		if conditions_container.get_child_count() > 1 and child is Label:
			continue
		tween.interpolate_deferred_callback(child, FOLD_TIME - (i * delay), "show")
		tween.start()
	return


func _on_Condition_checked(name: String, value: bool) -> void:
	if not value and conditions.has(name):
		conditions.erase(name)
		return
	conditions[name] = true
