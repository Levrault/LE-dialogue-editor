extends VBoxContainer

const STATE := ["unregistred_pristine", "unregistred_dirty", "registred_pristine", "registred_dirty", "exported"]

onready var dirty_registred_file := $DirtyRegistredFile
onready var dirty_registred_file_data := $DirtyRegistredFileData
onready var dirty_unregistred_file := $DirtyUnregistredFile
onready var dirty_unregistred_file_data := $DirtyUnregistredFileData
onready var edited_file := $EditedFile
onready var edited_file_data := $EditedFileData
onready var state := $State/Value
onready var previous_state := $PreviousState/Value


func _ready() -> void:
	dirty_registred_file.connect("toggled", self, "_on_Toggled", [dirty_registred_file_data])
	dirty_unregistred_file.connect("toggled", self, "_on_Toggled", [dirty_unregistred_file_data])
	edited_file.connect("toggled", self, "_on_Toggled", [edited_file_data])


func _process(delta) -> void:
	dirty_registred_file_data.text = JSON.print(FileManager.dirty_registred_files, "\t")
	dirty_unregistred_file_data.text = JSON.print(FileManager.dirty_unregistred_files, "\t")
	edited_file_data.text = JSON.print(FileManager.edited_file, "\t")
	state.text = STATE[FileManager.state]
	previous_state.text = STATE[FileManager.previous_state]


func _on_Toggled(button_pressed: bool, rich_text_label: RichTextLabel) -> void:
	rich_text_label.visible = button_pressed
