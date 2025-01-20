class_name Player extends Node3D

@export var camera_rotation_speed: float = 0.01;
@export var invert_camera_rotation: bool = false;

@onready var camera: CustomCamera = %Camera;
@onready var ball: RigidBody3D = %Ball;
@onready var camera_pivot: Node3D = %CameraPivot

const MAX_SPEED: int = 50; ## Maximum allowed speed (linear or angular).
const ACC_RATE: float = 3.0; ## The rate at which ball will speed up.
const STRAFE_MULTIPLIER: float = 2.0; ## Speed multiplier for left/right movement.
const BASE_FOV: float = 75.0; ## Default camera FOV.
const MAX_FOV: float = 110.0; ## Maximum allowed camera FOV.

var forward: Vector3 = Vector3.ZERO; ## The calculated forward direction, based on direction of camera.
var default_camera_orientation: Vector3;

func _ready() -> void:
	camera.fov = BASE_FOV;
	default_camera_orientation = camera_pivot.rotation;

func _process(_delta: float) -> void:
	# Reset camera's (parent) position to follow ball.
	camera_pivot.global_position = ball.global_position;

func _physics_process(_delta: float) -> void:
	# Set "forward" to be direction camera is facing.
	forward = camera.global_transform.basis.z.normalized().cross(Vector3.UP);
	
	# Limit ball velocities.
	ball.linear_velocity.x = clampf(ball.linear_velocity.x, -MAX_SPEED, MAX_SPEED);
	ball.linear_velocity.y = clampf(ball.linear_velocity.y, -MAX_SPEED, MAX_SPEED);
	ball.linear_velocity.z = clampf(ball.linear_velocity.z, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.x = clampf(ball.angular_velocity.x, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.y = clampf(ball.angular_velocity.y, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.z = clampf(ball.angular_velocity.z, -MAX_SPEED, MAX_SPEED);
	handle_input();

func _input(event: InputEvent) -> void:
	# If key is tapped, not held, reset camera rotation.
	if Input.is_action_just_pressed("rotate_camera"):
		await get_tree().create_timer(0.15).timeout;
		if not Input.is_action_pressed("rotate_camera"):
			reset_camera();
	# Rotate the camera if key is held and mouse is in motion.
	if event is InputEventMouseMotion and Input.is_action_pressed("rotate_camera"):
		var is_invert = 1 if invert_camera_rotation else -1;
		camera_pivot.rotate(Vector3(0,1,0), is_invert * event.relative.x * 0.01);

func move(dir) -> void:
	# Push the ball by applying torque along a direction at a passed in rate.
	ball.apply_torque_impulse(dir * ACC_RATE);
	
	# Change the FOV of the camera based on the speed of the ball.
	var new_fov = clampf(calculate_fov(), BASE_FOV, MAX_FOV);
	var tween = get_tree().create_tween();
	tween.tween_property(camera, "fov", new_fov, 0.15);

## Helper function to calculate FOV based on current speed limitation variables.
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

## Helper function to reset camera orientation.
func reset_camera() -> void:
	var tween = get_tree().create_tween();
	tween.tween_property(camera_pivot, "rotation", default_camera_orientation, 0.15);
