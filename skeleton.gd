extends RigidBody2D

@export var move_speed : float = 75

var collider_disabled_time : float = 0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	$TrackingEnemy.look_follow(state, global_transform, $TrackingEnemy.tracking_location)
	var motion_direction = ($TrackingEnemy.tracking_location - transform.get_origin()).normalized()
	linear_velocity = move_speed * motion_direction

func _on_body_entered(body: Node) -> void:
	if body.name == "PlayerAttack":
		if $StunTimer.is_stopped():
			var impulse_direction : Vector2 = (position - body.position).normalized()
			apply_impulse(impulse_direction * 100)
			$HealthComponent.take_damage(1)
			set_collision_mask_value(2, false)
			move_speed = 0
			$StunTimer.start()
	if body.name == "Player":
		var impulse_direction : Vector2 = (position - body.position).normalized()
		apply_impulse(impulse_direction * 100)
		if $AttackTimer.is_stopped():
			$AttackTimer.start()
			set_collision_mask_value(1, false)
			move_speed = 0
		
func _on_death() -> void:
	queue_free.call_deferred()

func _process(delta: float) -> void:
	pass

func _on_stun_timer_timeout() -> void:
	set_collision_mask_value(2, true)
	move_speed = 75

func _on_attack_timer_timeout() -> void:
	set_collision_mask_value(1, true)
	move_speed = 75
