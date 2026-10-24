extends Control

signal resume_game
signal quit_confirmed(value : bool)
signal quit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_quit_pressed():
	$StartGame.hide()
	$Controls.hide()
	$Quit.hide()
	$ConfirmQuit.show()
	$NoQuit.show()
	$Label.text = "Are you sure? Your progress will not be saved."
	var yes_quit = await quit_confirmed
	if yes_quit:
		quit.emit()
	else:
		$StartGame.show()
		$Controls.show()
		$Quit.show()
		$ConfirmQuit.hide()
		$NoQuit.hide()
		$Label.text = "Game Paused"
		

func _on_start_game_pressed() -> void:
	emit_signal("resume_game")


func _on_confirm_quit_pressed() -> void:
	quit_confirmed.emit(true)


func _on_no_quit_pressed() -> void:
	quit_confirmed.emit(false)
