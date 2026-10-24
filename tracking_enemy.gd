extends Node2D

var speed: float = 10

var tracking_location : Vector2

func look_follow(state: PhysicsDirectBodyState2D, current_transform: Transform2D, target_position: Vector2) -> void:
	var forward_local_axis: Vector2 = Vector2(1, 0)
	var forward_dir: Vector2 = (current_transform.basis_xform(forward_local_axis)).normalized()
	var target_dir: Vector2 = (target_position - current_transform.origin).normalized()
	var local_speed: float = clampf(speed, 0, acos(forward_dir.dot(target_dir)))
	if abs(forward_dir.dot(target_dir)) > 1e-4:
		state.angular_velocity = local_speed * forward_dir.cross(target_dir) / state.step
