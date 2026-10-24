extends Node2D

@export var skeleton_scene: PackedScene
var enemies : Array[Node2D] = []
@export var resource_point_scene: PackedScene
var resource_points : Array[Node2D] = []
var resource_point_count = 0

@onready var top_door = $TopDoor
@onready var bottom_door = $BottomDoor
@onready var right_door = $RightDoor
@onready var left_door = $LeftDoor

signal gained_resources(amount : int)

func _process(delta: float) -> void:
	var player_location = $Player.get_transform().origin
	for each in enemies:
		if is_instance_valid(each):
			each.get_node(^"TrackingEnemy").tracking_location = player_location

func _ready() -> void:
	_generate_mobs()
	_generate_resource_points()

func _generate_mobs() -> void:
	for i in randi_range(0, 2):
		var skeleton = skeleton_scene.instantiate()
		skeleton.position = Vector2(576, 324)
		enemies.push_back(skeleton)
		add_child(skeleton)

func _generate_resource_points():
	for i in randi_range(0, 2):
		resource_point_count += 1
		var point = resource_point_scene.instantiate()
		resource_points.push_back(point)
		point.position = get_node("ResourcePointSpawnLoc" + str(i+1)).position
		point.connect("gained_resources", _gained_resources)
		add_child(point)

func _gained_resources(amount : int):
	gained_resources.emit(amount)
