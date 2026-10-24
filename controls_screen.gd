extends CanvasLayer

signal back

func _on_button_pressed() -> void:
	emit_signal("back")
