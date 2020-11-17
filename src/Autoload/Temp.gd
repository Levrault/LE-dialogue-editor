# Manage unsaved and new file of the workspace
# If you create a new file and switch from the workspace view
# a temp file will be created to keep your file until the file is saved or the workspace closed
extends Node

signal temp_file_created

const UNSAVED_NAME := "unsaved"
var TEMP_PATH := "user://%s.%s.json"
var files := []


func create(workspace: String) -> void:
	var path = TEMP_PATH % [workspace, UNSAVED_NAME]
	files.append(path)
	Serialize.current_path = path
	Serialize.save()
