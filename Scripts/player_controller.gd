class_name Player extends Node3D

@export var MAX_SPEED: int = 50; ## Maximum allowed speed (linear or angular).
@export var ACC_RATE: float = 4.0; ## The rate at which ball will speed up.
@export var SLAM_FORCE: float = 10.0 ## The downward force applied to the ball when "slamming".
@export var STRAFE_MULTIPLIER: float = 2.5; ## Speed multiplier for left/right movement.
@export var BASE_FOV: float = 75.0; ## Default camera FOV.
@export var MAX_FOV: float = 110.0; ## Maximum allowed camera FOV.
@export var COLOR_OPTIONS: Array[Color]; ## List of colors to make the ball.

@onready var camera_pivot: Node3D = %CameraPivot;
@onready var camera: CustomCamera = %Camera;
@onready var ball: RigidBody3D = %Ball;
@onready var mesh: MeshInstance3D = %Mesh;
@onready var ball_light: OmniLight3D = %BallLight

var forward: Vector3 = Vector3.ZERO; ## The calculated forward direction, based on direction of camera.
var default_camera_orientation: Vector3;
var last_frames_veloctiy: Vector3 = Vector3.ZERO;

func _ready() -> void:
	set_emission(COLOR_OPTIONS[0]);
	camera.fov = BASE_FOV;
	default_camera_orientation = camera_pivot.rotation;
	ball.body_entered.connect(_on_hit_ground);

func _process(_delta: float) -> void:
	# Reset camera's (parent) position to follow ball.
	camera_pivot.global_position = ball.global_position;

func _physics_process(_delta: float) -> void:
	# Store the previous frame's velocity for calulating velocity on impacts.
	last_frames_veloctiy = ball.linear_velocity;
	
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
		var invert = 1 if Globals.is_look_inverted else -1;
		camera_pivot.rotate(Vector3(0,1,0), invert * event.relative.x * camera.camera_rotation_speed);

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
	if Input.is_action_pressed("slam"):
		ball.linear_velocity.y = clampf(ball.linear_velocity.y - SLAM_FORCE, -SLAM_FORCE, 0);

## Helper function to reset camera orientation.
func reset_camera() -> void:
	var tween = get_tree().create_tween();
	tween.tween_property(camera_pivot, "rotation", default_camera_orientation, 0.15);

func set_emission(color: Color) -> void:
	mesh.material_override.emission = color;
	ball_light.light_color = color;

func _on_hit_ground(body: Node3D) -> void:
	if body is not GridMap: return;
	if last_frames_veloctiy.y < -8:
		camera._camera_shake(0.25, 0.1);
		Globals.freeze_frame(0.4, 0.25);
