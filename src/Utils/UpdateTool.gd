extends Node
class_name UpdateTool

# Quick version update
static func migrate_to_last_version_only(legacy: Dictionary) -> void:
	legacy["info"]["version"] = ProjectSettings.get_setting("Info/version")

# WORKSPACE
# Add editor version
# Add configuration [has_portrait, has_name, dialogue_character_limit, choice_character_limit]
# remove depreciated path.file
# remove depreciated path.resource
static func migrate_workspace_v1_x_x_to_v1_0_3_beta(legacy: Dictionary, default_values: Dictionary) -> void:
	if not legacy.has("info"):
		legacy["info"] = default_values.info.duplicate(true)
	legacy["info"]["version"] = "v1.0.3-beta"

	if legacy.path.has("file"):
		legacy.path.erase("file")


# remove windows property, should be in global config
static func migrate_workspace_v1_0_3_beta_to_v1_0_3(legacy: Dictionary) -> void:
	legacy["info"]["version"] = "v1.0.3"
	legacy.info.erase("window_height")
	legacy.info.erase("window_width")
	legacy.info.erase("full_screen")


# EDITOR
# Save editor version inside the config file
# Add version editor
# Add has_name and has_portrait inside each link to workspace
static func migrate_editor_config_v1_x_x_to_v1_0_3_beta(legacy: Dictionary, global_default: Dictionary) -> void:
	if not legacy.has("info"):
		legacy["info"] = global_default.info.duplicate(true)
	legacy["info"]["version"] = "v1.0.3-beta"

	for workspace in legacy.workspaces.list:
		if workspace.get("has_portrait") == null:
			workspace["has_portrait"] = true
		if workspace.get("has_name") == null:
			workspace["has_name"] = true


# Add windows size property inside the global config 
static func migrate_editor_v1_0_3_beta_to_v1_0_3(legacy: Dictionary, global_default: Dictionary) -> void:
	legacy["info"]["version"] = "v1.0.3"
	if not legacy["info"].has("window_height"):
		legacy["info"]["window_height"] = global_default.info.window_height
	if not legacy["info"].has("window_width"):
		legacy["info"]["window_width"] = global_default.info.window_width