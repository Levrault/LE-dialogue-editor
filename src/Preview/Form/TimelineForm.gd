# Create and sync all available conditions
# Every fields created
# - ConditionCheckBox
# - ConditionInput
# will emit their own custom signal to update the condition dictionary
# This dictionary will be send to the Preview scene to predicate the path
#
# See TimelineFieldsContainer for input creation/sync 
extends VBoxContainer

const FOLD_TIME := .075

var conditions := {}
onready var fields_container := $MarginContainer/TimelineFieldsContainer
onready var fold_button := $HBoxContainer/Fold
onready var unfold_button := $HBoxContainer/UnFold
onready var title := $Title
onready var tween := $Tween


func reset_fold_button() -> void:
	fold_button.show()
	unfold_button.hide()


# Hide field with a "fake" animation fold animation
func fold() -> void:
	title.hide()
	fold_button.hide()
	unfold_button.show()

	var delay := FOLD_TIME / fields_container.get_child_count()
	var conditions_children := fields_container.get_children()
	conditions_children.invert()
	for i in range(0, fields_container.get_child_count()):
		tween.interpolate_deferred_callback(conditions_children[i], FOLD_TIME - (i * delay), "hide")
		tween.start()


# Show field with a "fake" animation unfold animation
func unfold() -> void:
	title.show()
	fold_button.show()
	unfold_button.hide()

	var delay := FOLD_TIME / fields_container.get_child_count()
	var conditions_children := fields_container.get_children()
	conditions_children.invert()

	for i in range(0, fields_container.get_child_count()):
		var child = conditions_children[i]
		# manage empty label
		if fields_container.get_child_count() > 1 and child is Label:
			continue
		tween.interpolate_deferred_callback(child, FOLD_TIME - (i * delay), "show")
		tween.start()
	return


# Update boolean value inside condition dictionary
# @param {String} name - field's name
# @param {bool} value
func _on_Field_checked(name: String, value: bool) -> void:
	conditions[name] = value


# Update int value inside condition dictionary
# @param {String} name - field's name
# @param {int|string} value - value of the field (can be anything)
func _on_Input_changed(name: String, value) -> void:
	conditions[name] = value
	Events.emit_signal("preview_button_activated")


# Active/inactive an input value from the condtion
# @param {String} name - field's name
# @param {int|string} value - value of the field (can be anything)
func _on_Status_changed(name: String, active: bool, value) -> void:
	if value == null:
		return

	Events.emit_signal("preview_button_activated")

	if not active:
		if conditions.has(name):
			conditions.erase(name)
		return

	conditions[name] = value
