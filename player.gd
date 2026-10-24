extends CharacterBody2D

@export var speed = 200
@export var knockback_strength = 1000
@export var player_attack : PackedScene
var health_potion_count : int

var _can_take_damage : bool = true
var _can_attack : bool = true

const POTION_HEAL_AMOUNT : int = 3

signal health_changed()
signal game_over()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and _can_attack:
		var attack = player_attack.instantiate()
		attack.position = $AttackSource.position
		attack.rotation = $AttackSource.rotation
		add_child(attack)
		_can_attack = false
		$AttackTimer.start()

func get_input() -> Vector2:
	var input_dir : Vector2 = Input.get_vector("left", "right", "up", "down")
	if input_dir != Vector2(0, 0):
		$AttackSource.position = input_dir * 40.0
		$AttackSource.rotation = input_dir.angle()
	if rotation >= PI:
		rotation -= PI
	return input_dir

func _physics_process(delta):
	var input_velocity = get_input() * speed
	_handle_player_collisions()
	var collision_velocity =  _handle_player_collisions()
	velocity = input_velocity + collision_velocity
	#if collision_velocity.length() > 0:
		#breakpoint
	move_and_slide()
	
func _process(delta: float) -> void:
	pass

func _handle_player_collisions() -> Vector2:
	for i in get_slide_collision_count(): 
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if is_instance_valid(collider):
			if collider.is_in_group("enemies"):
				if _can_take_damage:
					$HealthComponent.take_damage(1)
					$InvincibilityTimer.start()
					_can_take_damage = false
					emit_signal("health_changed")
				return collision.get_normal() * speed + collision.get_collider_velocity()
			elif collider.is_class("StaticBody2D"):
				return collision.get_normal() * speed
	return Vector2(0, 0)

func _on_death() -> void:
	emit_signal("game_over")

func _on_attack_timer_timeout() -> void:
	_can_attack = true

func _on_invincibility_timer_timeout() -> void:
	_can_take_damage = true
