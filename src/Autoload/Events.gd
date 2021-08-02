extends Node

# workspace creation
signal new_workspace_dialog_displayed
signal workspace_new_file_dialog_displayed(node)
signal workspace_open_file_dialog_displayed
signal recents_table_changed
signal workspace_unsaved_file_added
signal workspace_files_updated
signal workspace_file_selection_changed(button)

# layout
signal layout_workspace_explorer_drawer_toggled
signal layout_workspace_explorer_drawer_closed
signal layout_preview_toggled
signal layout_preview_closed

# preview
signal preview_started(conditions)
signal preview_finished
signal preview_button_activated
signal preview_predicated_route_displayed(uuid_list)
signal preview_choices_displayed

# confirmation modal
signal confirmation_relation_pop_up_displayed(text)
signal confirmation_relation_answered(value)

# portrait manager modal
signal characters_pop_up_displayed
signal characters_list_changed

# creation
signal graph_node_added(node)
signal graph_node_loaded(node)
signal graph_node_selected(uuid)
signal graph_edit_reloaded_started
signal graph_edit_reloaded_finished

# graph
signal graph_edit_reloaded
signal graph_edit_loaded

# change language
signal locale_changed(value)
signal locale_pop_up_displayed

# manage locale
signal i18n_changed

# creation
signal dialogue_node_created(data)
signal choice_node_created(data)
signal condition_node_created(data)
signal signal_node_created(data)

signal node_deleted(from, from_slot, to, to_slot)

# signals
signal signals_window_displayed(uuid)

# relations
signal root_to_dialogue_relation_created(from)
signal root_to_dialogue_relation_deleted
signal root_to_condition_relation_created(to)
signal root_to_condition_relation_deleted(to)

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
signal condition_to_choice_relation_created(from, to)
signal condition_to_choice_relation_deleted(from)

# choice to conditions
signal choice_to_dialogue_relation_created(parent, from, to)
signal choice_to_dialogue_relation_deleted(from)

# condition value
signal condition_value_added
signal condition_value_deleted(value)

# menu
signal menu_popup_displayed(name)
signal file_dialog_opened(mode)
signal file_dialog_export_opened

# expand text
signal expand_text_dialogued_opened(owner)

# file
signal file_title_changed(title)
signal file_loaded
signal unsaved_file_displayed
signal offset_changed(uuid, type, offset)
signal connection_request_loaded(from, from_slot, to, to_slot)

# notification
signal notification_displayed(type, message)

# help
signal about_pop_up_displayed

# spinner
signal spinner_displayed
signal spinner_hidden
