extends Node2D

@onready var interactable: Area2D = $Interactable
@onready var color_rect: ColorRect = $ColorRect

signal gained_resources(amount : int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact(): 
	interactable.is_interactable = false
	gained_resources.emit(randi_range(1, 2))
	color_rect.color = Color(0x005300ff)

func reset():
	interactable.is_interactable = true
	color_rect.color = Color(0x50341aff)
