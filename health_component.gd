extends Node

@export var health : int

signal took_damage
signal died

func take_damage(amount : int):
	health -= amount
	if (health <= 0):
		died.emit()
	else:
		took_damage.emit()
