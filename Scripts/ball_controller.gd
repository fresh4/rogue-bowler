extends Node3D

@onready var camera: Camera3D = %Camera;
@onready var ball: RigidBody3D = %Ball;

const MAX_SPEED: int = 50; # Maximum allowed speed (linear or angular).
const ACC_RATE: float = 3.0; # The rate at which ball will speed up.
const STRAFE_MULTIPLIER: float = 2.0; # Speed multiplier for left/right movement.
const BASE_FOV: float = 75.0; # Default camera FOV.
const MAX_FOV: float = 110.0; # Maximum allowed camera FOV.

var forward: Vector3 = Vector3.ZERO; # The calculated forward direction, based on direction of camera.

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	# Reset camera's (parent) position to follow ball.
	global_position = ball.global_position;

func _physics_process(_delta: float) -> void:
	# Set "forward" to be direction camera is facing TODO not sure if works.
	forward = camera.transform.basis.z;
	
	# Limit ball velocities.
	ball.linear_velocity.x = clampf(ball.linear_velocity.x, -MAX_SPEED, MAX_SPEED);
	ball.linear_velocity.y = clampf(ball.linear_velocity.y, -MAX_SPEED, MAX_SPEED);
	ball.linear_velocity.z = clampf(ball.linear_velocity.z, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.x = clampf(ball.angular_velocity.x, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.y = clampf(ball.angular_velocity.y, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.z = clampf(ball.angular_velocity.z, -MAX_SPEED, MAX_SPEED);
	handle_input();

func move(dir) -> void:
	# Push the ball by applying torque along a direction at a passed in rate.
	ball.apply_torque_impulse(dir * ACC_RATE);
	
	# Change the FOV of the camera based on the speed of the ball.
	var new_fov = clampf(calculate_fov(), BASE_FOV, MAX_FOV);
	var tween = get_tree().create_tween();
	tween.tween_property(camera, "fov", new_fov, 0.15);

func calculate_fov() -> float:
	return BASE_FOV + ( MAX_FOV - BASE_FOV ) * ( ball.linear_velocity.length() / 30 );

func handle_input() -> void:
	if Input.is_action_pressed("forward"):
		move(forward);
	if Input.is_action_pressed("backward"):
		move(-forward);
	if Input.is_action_pressed("left"):
		move(-forward.cross(Vector3.UP) * STRAFE_MULTIPLIER);
	if Input.is_action_pressed("right"):
		move(forward.cross(Vector3.UP) * STRAFE_MULTIPLIER);
