@tool
extends PowerUp

@export var jump_power: int = 10;

func activate(ball: RigidBody3D) -> void:
	ball.linear_velocity.y = jump_power;
