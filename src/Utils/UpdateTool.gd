extends Node
class_name UpdateTool

# Add editor version
# each file now support configuration [has_portrait, has_name, dialogue_character_limit, choice_character_limit]
# remove depreciated path.file
# remove depreciated path.resource
static func migrate_workspace_v1_x_x_to_v1_0_3_beta(legacy: Dictionary, default_values: Dictionary) -> void:
	if not legacy.has("info"):
		legacy["info"] = default_values.info.duplicate(true)
	legacy["info"]["version"] = ProjectSettings.get_setting("Info/version")

	if legacy.path.has("file"):
		legacy.path.erase("file")

# Save editor version inside the config file
static func migrate_editor_config_v1_x_x_to_v1_0_3_beta(legacy: Dictionary, global_default: Dictionary) -> void:
	if not legacy.has("info"):
		legacy["info"] = global_default.info.duplicate(true)
	legacy["info"]["version"] = ProjectSettings.get_setting("Info/version")

	for workspace in legacy.workspaces.list:
		if workspace.get("has_portrait") == null:
			workspace["has_portrait"] = true
		if workspace.get("has_name") == null:
			workspace["has_name"] = true
