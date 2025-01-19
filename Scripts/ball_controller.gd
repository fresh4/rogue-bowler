extends Node3D

@onready var camera: Camera3D = %Camera;
@onready var ball: RigidBody3D = %Ball;

const MAX_SPEED: int = 300;
const ACC_RATE: float = 10;

var forward: Vector3 = Vector3.ZERO;

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	global_position = ball.global_position;

func _physics_process(_delta: float) -> void:
	forward = camera.transform.basis.z;
	ball.linear_velocity.x = clampf(ball.linear_velocity.x, -MAX_SPEED, MAX_SPEED);
	ball.linear_velocity.y = clampf(ball.linear_velocity.y, -MAX_SPEED, MAX_SPEED);
	ball.linear_velocity.z = clampf(ball.linear_velocity.z, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.x = clampf(ball.angular_velocity.x, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.y = clampf(ball.angular_velocity.y, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.z = clampf(ball.angular_velocity.z, -MAX_SPEED, MAX_SPEED);

func _input(event: InputEvent) -> void:
	if event.is_action("forward"):
		move(forward);
	if event.is_action("backward"):
		move(-forward);
	if event.is_action("left"):
		move(-forward.cross(Vector3.UP));
	if event.is_action("right"):
		move(forward.cross(Vector3.UP));

func move(dir) -> void:
	ball.apply_torque_impulse(dir * ACC_RATE);
