extends Area2D

var linked_door
@onready var spawn_location: Marker2D = $SpawnLocation

signal door_entered(door)

func _on_door_entered(body: Node2D) -> void:
	if body.name == "Player":
		door_entered.emit(self)
