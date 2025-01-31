@tool
extends PowerUp

@export var boost_power: int = 1000;

func activate(ball: RigidBody3D) -> void:
	ball.apply_central_force(player.forward.cross(Vector3.UP) * boost_power * ball.mass);
	queue_free();
