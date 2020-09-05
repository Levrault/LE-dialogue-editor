extends Node

# layout
signal layout_folder_view_toggled
signal layout_preview_toggled

# creation
signal graph_node_added(node)
signal graph_node_loaded(node)
signal graph_edit_reloaded_started
signal graph_edit_reloaded_finished

# graph
signal graph_edit_reloaded
signal graph_edit_loaded

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
signal root_to_dialogue_relation_changed(from)
signal root_to_condition_relation_changed(to)

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

# condition value
signal condition_value_added
signal condition_value_deleted(value)

# menu
signal menu_popup_displayed(name)
signal file_dialog_opened(mode)
signal file_dialog_export_opened

# file
signal file_loaded
signal offset_changed(uuid, type, offset)
signal connection_request_loaded(from, from_slot, to, to_slot)
signal unsaved_file_displayed

# notification
signal notification_displayed(type, message)

# GAME ENGINE
# player
signal player_choice_started

# dialogue
signal dialogue_started
signal dialogue_changed(name, portrait, message)
signal dialogue_text_displayed
signal dialogue_last_text_displayed
signal dialogue_finished
signal dialogue_last_dialogue_displayed
signal dialogue_animation_skipped
signal dialogue_choices_changed(choices)
signal dialogue_choices_displayed
signal dialogue_choices_finished(choices)
signal dialogue_choices_pressed
signal dialogue_timed_out
signal dialogue_timed(value)

# cinematic
signal cinematic_started
signal cinematic_ended

# transitions
signal transition_started(anim_name)
signal transition_mid_animated
signal transition_finished
