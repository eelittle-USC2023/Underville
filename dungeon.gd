extends Node

var current_scene : Node
signal finished_generation

var town : Node2D
var player : Node2D
var player_health : int
@export var dungeon_room_scene: PackedScene
var dungeon_rooms = []
var current_room : Node2D
var quest_manager : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_scene = $MainMenu

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("pause"):
		get_tree().paused = true
		scene_change("res://pause_menu.tscn")
		_set_up_pause_menu.call_deferred()

func _set_up_pause_menu():
	get_node("PauseMenu/StartGame").connect("pressed", _back_to_current_room)
	get_node("PauseMenu/Controls").connect("pressed", _to_controls)
	get_node("PauseMenu").connect("quit", to_main_menu)

func _to_controls():
	$HUD.hide()
	current_scene.hide()
	$ControlsScreen.show()
	
func _exit_controls():
	if current_scene.name == "PauseMenu":
		$HUD.show()
	current_scene.show()
	$ControlsScreen.hide()
	
func to_main_menu():
	get_tree().paused = false
	$HUD.hide()
	scene_change("res://main_menu.tscn")
	_reset.call_deferred()

func _reset():
	$MainMenu/Controls.connect("pressed", _to_controls)
	$MainMenu/StartGame.connect("pressed", _on_main_menu_start_game)
	$MainMenu/Exit.connect("pressed", _on_main_menu_exit)
	town.free()
	for room in dungeon_rooms:
		room.free()
	dungeon_rooms.clear()
	dungeon_rooms = []
	quest_manager.free()

func _on_player_enter_door(door_entered):
	var room_entered = door_entered.linked_door.get_parent()
	_deferred_room_change.call_deferred(room_entered, door_entered.linked_door.get_node("SpawnLocation").global_position)

func _deferred_room_change(room, player_spawn_position):
	remove_child(current_room)
	player = room.get_node("Player")
	player.set_position(player_spawn_position)
	player.get_node("HealthComponent").health = player_health
	add_child(room)
	current_room = room
	current_scene = current_room

func _link_doors(door1, door2):
	if door1.linked_door:
		door1.linked_door.linked_door = null
		door1.linked_door.hide()
		door1.linked_door.monitoring = false
	if door2.linked_door:
		door2.linked_door.linked_door = null
		door2.linked_door.hide()
		door2.linked_door.monitoring = false
	door1.monitoring = true
	door2.monitoring = true
	door1.show()
	door2.show()
	door1.linked_door = door2
	door2.linked_door = door1
	if !door1.door_entered.is_connected(_on_player_enter_door):
		door1.door_entered.connect(_on_player_enter_door)
	if !door2.door_entered.is_connected(_on_player_enter_door):
		door2.door_entered.connect(_on_player_enter_door)

func _on_player_health_changed() -> void:
	player_health = player.get_node("HealthComponent").health
	$HUD.update(player_health)

func scene_change(path):
	if is_instance_of(path, TYPE_STRING):
		_deferred_scene_change.call_deferred(path)

func _back_to_current_room():
	current_scene.queue_free()
	add_child.call_deferred(current_room)
	set_deferred("current_scene", current_room)
	get_tree().paused = false

func _deferred_scene_change(path):
	remove_child(current_scene)
	var is_scene_dungeon : bool = false
	if is_same(current_scene, town):
		is_scene_dungeon = true
	if !is_scene_dungeon:
		for room in dungeon_rooms:
			if(is_same(current_scene, room)):
				is_scene_dungeon = true
	
	if !is_scene_dungeon:
		current_scene.free()
	
	var s : PackedScene = load(path)
	current_scene = s.instantiate()
	add_child(current_scene)

func _on_main_menu_start_game() -> void:
	scene_change("res://game_explainer.tscn")
	_generate_dungeon.call_deferred()
	await finished_generation
	var begin_button : Button = current_scene.get_node("BeginButton")
	begin_button.show()
	await begin_button.pressed
	current_scene.queue_free()
	set_deferred("current_scene", current_room)
	add_child.call_deferred(town)
	$HUD.update(player_health)
	$HUD.show.call_deferred()


func _generate_dungeon():
	var t : PackedScene = load("res://town.tscn")
	town = t.instantiate()
	add_child(town)
	remove_child(town)
	town.set_interacts(quest_npc_interact, bed_interact)
	player = town.get_node("Player")
	player_health = player.get_node("HealthComponent").health
	player.connect("health_changed", _on_player_health_changed)
	player.connect("game_over", game_over)
	var q : PackedScene = load("res://quest_manager.tscn")
	quest_manager = q.instantiate()
	quest_manager.connect("game_over", game_over)
	quest_manager.connect("game_won", game_won)
	var resource_point_count : int = 0
	while resource_point_count < 10:
		for i in randi_range(5, 15):
			var dungeon_room = dungeon_room_scene.instantiate()
			add_child(dungeon_room)
			remove_child(dungeon_room)
			dungeon_rooms.push_back(dungeon_room)
			dungeon_room.connect("gained_resources", _increase_resources)
			dungeon_room.get_node("Player").connect("game_over", game_over)
			dungeon_room.get_node("Player").connect("health_changed", _on_player_health_changed)
			if i > 0:
				_link_doors(dungeon_rooms[i-1].bottom_door, dungeon_rooms[i].top_door)
			resource_point_count += dungeon_room.resource_point_count
	current_room = town
	_link_doors(town.door, dungeon_rooms[0].top_door)
	town.set_room_npc_lines(["There are " + str(dungeon_rooms.size()) + " rooms in the dungeon."])
	emit_signal("finished_generation")

func _increase_resources(amount : int):
	quest_manager.increase_resources(amount)

func quest_npc_interact():
	town.set_quest_npc_lines(["Day " + str(quest_manager.day) \
		+ ". You still need " \
		+ (str(quest_manager.quests[quest_manager.current_quest].x - quest_manager.resource_count) if \
			quest_manager.quests[quest_manager.current_quest].x - quest_manager.resource_count > 0 else \
			str(0)) \
		+ " resources by Day " + str(quest_manager.quests[quest_manager.current_quest].y) \
		+ " to complete your quest."])
	town.quest_npc.get_next_line()

func bed_interact():
	quest_manager.next_day()
	for room in dungeon_rooms:
		for point in room.resource_points:
			point.reset()

func game_over():
	scene_change("res://lose_screen.tscn")
	_deferred_win_lose_button_connect.call_deferred()

func game_won():
	scene_change("res://win_screen.tscn")
	_deferred_win_lose_button_connect.call_deferred()

func _deferred_win_lose_button_connect():
	current_scene.get_node("Button").connect("pressed", to_main_menu)
	pass

func _on_main_menu_exit() -> void:
	get_tree().quit()
