extends Node

enum Type { equal, greater, lower, different }


func get_operator(operator: int) -> String:
	if operator == Type.greater:
		return "greater"
	if operator == Type.lower:
		return "lower"
	if operator == Type.different:
		return "different"

	return "equal"


func get_operator_enum(operator: String) -> int:
	if operator == "greater":
		return Type.greater
	if operator == "lower":
		return Type.lower
	if operator == "different":
		return Type.different

	return Type.equal
