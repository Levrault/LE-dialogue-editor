extends Node

# Merge two array together (no deep merge)
# @param {Dictionary} initial_values
# @param {Dictionary} values
# @returns {Dictionary}
static func merge(initial_values: Dictionary, values: Dictionary) -> Dictionary:
	var new_values: Dictionary = initial_values.duplicate()
	for key in initial_values.keys():
		if values.has(key):
			new_values[key] = values[key]

	return new_values
