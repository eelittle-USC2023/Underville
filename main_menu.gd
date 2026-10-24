extends Control

signal start_game
signal to_controls
signal exit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_pressed() -> void:
	emit_signal("start_game")


func _on_controls_pressed() -> void:
	emit_signal("to_controls")


func _on_exit_pressed() -> void:
	exit.emit()
