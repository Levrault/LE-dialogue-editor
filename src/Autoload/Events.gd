extends Node

# creation
signal graph_node_added(node)
signal graph_node_loaded(node)

# change language
signal locale_changed(value)

# creation
signal dialogue_node_created(data)
signal choice_node_created(data)
signal condition_node_created(data)
signal signal_node_created(data)

signal node_deleted(from, from_slot, to, to_slot)

# signals
signal signals_window_displayed(uuid)

# relations
signal start_to_dialogue_relation_changed(from)

signal dialogue_to_dialogue_relation_created(from, to)
signal dialogue_to_dialogue_relation_deleted(from)

signal dialogue_to_choice_relation_created(from, to)
signal dialogue_to_choice_relation_deleted(from, to)

signal dialogue_to_signal_relation_created(from, to)
signal dialogue_to_signal_relation_deleted(from)

signal dialogue_to_condition_relation_created(from, to)
signal dialogue_to_condition_relation_deleted(from)

signal condition_to_dialogue_relation_created(from, to)
signal condition_to_dialogue_relation_deleted(from)

# choice to conditions
signal choice_to_dialogue_relation_created(from, to)
signal choice_to_dialogue_relation_deleted(from)

# menu
signal menu_popup_displayed(name)
signal file_dialog_opened(mode)

# file
signal file_loaded
signal offset_changed(uuid, type, offset)
signal connection_request_loaded(from, from_slot, to, to_slot)
