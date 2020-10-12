extends OptionButton


func _ready() -> void:
	connect("item_selected", self, "_on_Type_selected")
	add_item("Equal", Operator.Type.equal)
	add_item("Greater", Operator.Type.greater)
	add_item("Lower", Operator.Type.lower)
	add_item("Different", Operator.Type.different)
	selected = Operator.Type.equal


func _on_Type_selected(index: int) -> void:
	owner.operator = Operator.get_operator(index)
