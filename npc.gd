extends Node2D

@onready var interactable: Area2D = $Interactable
@onready var label: Label = $Label
var lines : Array
var current_line: int = 0

func set_interact(c : Callable):
	interactable.interact = c


func get_next_line():
	if current_line < lines.size() - 1:
		current_line += 1
	else:
		current_line = 0
	label.text = lines[current_line]
