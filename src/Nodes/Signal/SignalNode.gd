extends GraphEditorNode

enum Type { empty, string, vector2, number }
const TYPE = Editor.Type.signal_node

var selected_type = Type.empty

onready var container := $Container
onready var add_field := $Container/AddSignal
onready var signal_name := $Container/FieldContainer/SignalName
onready var type_option := $Container/TypeContainer/TypeOption
onready var vector2_field := $Container/Vector2
onready var number_field := $Container/Number
onready var string_field := $Container/String


func _ready() -> void:
	type_option.connect("item_selected", self, "_on_Type_selected")
	type_option.add_item("Empty", Type.empty)
	type_option.add_item("String", Type.string)
	type_option.add_item("Vector2", Type.vector2)
	type_option.add_item("Number", Type.number)
	type_option.selected = Type.empty
	vector2_field.hide()
	number_field.hide()
	string_field.hide()
	add_field.is_disabled = true


# prevent addind an existing value
func has_duplicate_value(value: String) -> bool:
	for v in values.data:
		if v == value:
			return true
	return false


func is_submitable() -> bool:
	if selected_type == Type.vector2:
		if not vector2_field.is_valid():
			return false

	if selected_type == Type.number:
		if not number_field.is_valid():
			return false

	if selected_type == Type.string:
		if not string_field.is_valid():
			return false

	return not signal_name.text.empty()


func params_to_string() -> String:
	if selected_type == Type.vector2:
		return "(%s,%s)" % [vector2_field.x.text, vector2_field.y.text]

	if selected_type == Type.number:
		return number_field.field.text

	if selected_type == Type.string:
		return '"%s"' % string_field.field.text

	return "null"


func type_to_string() -> String:
	var result := ''
	match selected_type:
		Type.empty:
			result = 'empty'
		Type.string:
			result = 'String'
		Type.vector2:
			result = 'Vector2'
		Type.number:
			result = 'Number'
	return result


func get_values() -> Dictionary:
	if selected_type == Type.vector2:
		return {"Vector2": {"x": vector2_field.x.text, "y": vector2_field.y.text}}

	if selected_type == Type.number:
		return {"Number": number_field.field.text}

	if selected_type == Type.string:
		return {"String": string_field.field.text}

	return {}


func reset_type() -> void:
	selected_type = Type.empty
	number_field.field.clear()
	string_field.field.clear()
	vector2_field.x.clear()
	vector2_field.y.clear()

	vector2_field.hide()
	number_field.hide()
	string_field.hide()


# Remove delete value from values dictionnary
# and use rect_size to resize the node
func _on_Signal_deleted(value_to_delete: String, field_rect_size: Vector2) -> void:
	values.erase(value_to_delete)
	container.rect_size = Vector2(container.rect_size.x, container.rect_size.y - field_rect_size.y)
	rect_size = Vector2(rect_size.x, rect_size.y - (field_rect_size.y * 2))


func _on_Type_selected(index: int) -> void:
	selected_type = index
	if index == Type.empty:
		vector2_field.hide()
		number_field.hide()
		string_field.hide()
		return

	if index == Type.vector2:
		add_field.is_disabled = true
		vector2_field.show()
		number_field.hide()
		string_field.hide()
		return

	if index == Type.number:
		add_field.is_disabled = true
		number_field.show()
		vector2_field.hide()
		string_field.hide()
		return

	if index == Type.string:
		add_field.is_disabled = true
		string_field.show()
		number_field.hide()
		vector2_field.hide()
		return
