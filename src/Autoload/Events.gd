extends Node

# creation
signal graph_node_added(node)

# creation
signal dialogue_node_created(uuid)
signal choice_node_created(uuid)

# relations
signal dialogue_to_dialogue_relation_created(from, to)
signal dialogue_to_dialogue_relation_deleted(from, to)

signal dialogue_to_choice_relation_created(from, to)
signal dialogue_to_choice_relation_deleted(from, to)

signal choice_to_dialogue_relation_created(from, to)
signal choice_to_dialogue_relation_deleted(from, to)

# menu
signal menu_popup_displayed(name)
