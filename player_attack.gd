extends RigidBody2D

var rotate_speed: float = 2*PI
var delay : float = 0.5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.angular_velocity = rotate_speed

func _process(delta: float) -> void:
	delay -= delta
	if (delay <= 0):
		queue_free.call_deferred()
