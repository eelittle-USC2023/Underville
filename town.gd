extends Node2D

@onready var door = $Door
@onready var room_npc: Node2D = $RoomNPC
@onready var quest_npc: Node2D = $QuestNPC
@onready var bed: Node2D = $Bed

func set_room_npc_lines(lines : Array):
	room_npc.lines = lines

func set_quest_npc_lines(lines : Array):
	quest_npc.lines = lines

func set_interacts(q_call : Callable, b_call : Callable):
	quest_npc.set_interact(q_call)
	bed.get_node("Interactable").interact = b_call
	room_npc.set_interact(room_npc.get_next_line)
