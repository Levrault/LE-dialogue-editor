extends WindowDialog


func _ready() -> void:
	Events.connect("signals_window_displayed", self, "_on_Displayed")


func _on_Displayed(uuid: String) -> void:
	show()
