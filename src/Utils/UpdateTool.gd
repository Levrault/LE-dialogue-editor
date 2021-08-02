extends Node
class_name UpdateTool

static func migrate_v1_x_x_to_v1_0_3_beta(legacy: Dictionary) -> void:
	if not legacy.has("info"):
		legacy["info"] = Config.DEFAULT_VALUES.info.duplicate(true)
	legacy["info"]["version"] = ProjectSettings.get_setting("Info/version")

	if legacy.path.has("file"):
		legacy.path.erase("file")
	if legacy.path.has("resource"):
		legacy.path.erase("resource")
