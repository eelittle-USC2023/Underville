extends Node

var resource_count : int = 0
var day : int = 1
var quests : Array[Vector2i] = [Vector2i(20, 5), Vector2i(40, 10), Vector2i(70, 15), Vector2i(115, 20)]
var current_quest : int = 0

signal game_over()
signal game_won()

func increase_resources(amount : int):
	resource_count += amount

func next_day():
	day += 1
	for quest in quests:
		if(day == quest.y):
			if (resource_count < quest.x):
				game_over.emit()
			else:
				current_quest += 1
				if current_quest == 4:
					game_won.emit()
