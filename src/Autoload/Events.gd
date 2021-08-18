extends Node

# preview
signal preview_started(conditions)
signal preview_finished
signal preview_button_activated
signal preview_predicated_route_displayed(uuid_list)
signal preview_choices_displayed

# confirmation modal
signal confirmation_relation_pop_up_displayed(text)
signal confirmation_relation_answered(value)

# expand text
signal expand_text_dialogued_opened(owner)

# debug
signal debug_mode_activated
signal debug_button_pressed
signal debug_view_displayed

# graph
signal graph_node_added(node)
signal graph_node_loaded(node)
signal graph_node_selected(uuid)
signal graph_edit_reloaded_started
signal graph_edit_reloaded_finished
signal graph_edit_reloaded
signal graph_edit_loaded

# help
signal about_pop_up_displayed

# file
signal file_title_changed(title)
signal file_loaded
signal unsaved_file_displayed
signal offset_changed(uuid, type, offset)
signal connection_request_loaded(from, from_slot, to, to_slot)

# layout
signal layout_workspace_explorer_drawer_toggled
signal layout_workspace_explorer_drawer_closed
signal layout_preview_toggled
signal layout_preview_closed

# locale
signal i18n_changed
signal locale_changed(value)
signal locale_pop_up_displayed

# menu
signal menu_popup_displayed(name)
signal file_dialog_opened(mode)
signal file_dialog_export_opened

# node - creation
signal dialogue_node_created(data)
signal choice_node_created(data)
signal condition_node_created(data)
signal signal_node_created(data)
signal node_deleted(from, from_slot, to, to_slot)

# node - relations
# --root--
signal root_to_dialogue_relation_created(from)
signal root_to_dialogue_relation_deleted
signal root_to_condition_relation_created(to)
signal root_to_condition_relation_deleted(to)

# --choice--
signal choice_to_dialogue_relation_created(parent, from, to)
signal choice_to_dialogue_relation_deleted(from)

# --dialogue--
signal dialogue_to_dialogue_relation_created(from, to)
signal dialogue_to_dialogue_relation_deleted(from)

signal dialogue_to_choice_relation_created(from, to)
signal dialogue_to_choice_relation_deleted(from, to)

signal dialogue_to_signal_relation_created(from, to)
signal dialogue_to_signal_relation_deleted(from)

signal dialogue_to_condition_relation_created(from, to)
signal dialogue_to_condition_relation_deleted(from)

# --conditions--
signal condition_to_dialogue_relation_created(from, to)
signal condition_to_dialogue_relation_deleted(from)
signal condition_to_choice_relation_created(from, to)
signal condition_to_choice_relation_deleted(from)
signal condition_value_added
signal condition_value_deleted(value)

# new file
signal new_file_button_pressed

# notification
signal notification_displayed(type, message)

# portrait manager modal
signal characters_pop_up_displayed
signal characters_list_changed

# quit
signal quit_workspace_button_pressed

# save
signal save_file_button_pressed

# signals
signal signals_window_displayed(uuid)

# spinner
signal spinner_displayed
signal spinner_hidden

# recent list
signal recents_table_changed

# toolbox
signal toolbox_preview_button_pressed
signal toolbox_json_button_pressed
signal toolbox_locale_button_pressed
signal toolbox_characters_button_pressed
signal toolbox_json_displayed(values)

# workspace creation
signal workspace_new_form_displayed
signal workspace_new_file_dialog_displayed(node)
signal workspace_open_file_dialog_displayed
signal workspace_import_form_displayed
signal workspace_import_file_dialog_displayed
signal workspace_open_resource_folder_dialog_displayed
signal workspace_unsaved_file_added
signal workspace_files_updated
signal workspace_file_selection_changed(button)
