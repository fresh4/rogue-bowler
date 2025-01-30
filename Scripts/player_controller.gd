class_name Player extends Node3D

@export var MAX_SPEED: int = 50; ## Maximum allowed speed (linear or angular).
@export var ACC_RATE: float = 8.0; ## The rate at which ball will speed up.
@export var SLAM_FORCE: float = 1500.0 ## The downward force applied to the ball when "slamming".
@export var STRAFE_MULTIPLIER: float = 2.5; ## Speed multiplier for left/right movement.
@export var BASE_FOV: float = 75.0; ## Default camera FOV.
@export var MAX_FOV: float = 110.0; ## Maximum allowed camera FOV.
@export var COLOR_OPTIONS: Array[Color]; ## List of colors to make the ball.

@onready var camera_pivot: Node3D = %CameraPivot;
@onready var camera: CustomCamera = %Camera;
@onready var ball: RigidBody3D = %Ball;
@onready var mesh: MeshInstance3D = %Mesh;
@onready var ball_light: OmniLight3D = %BallLight
@onready var animator: AnimationPlayer = $Animator

var forward: Vector3 = Vector3.ZERO; ## The calculated forward direction, based on direction of camera.
var default_camera_orientation: Vector3;
var last_frames_velocity: Vector3 = Vector3.ZERO;
var level_manager: LevelManager;

func _ready() -> void:
	level_manager = get_tree().get_first_node_in_group("LevelManager");
	animator.pause();
	set_emission(COLOR_OPTIONS[0]);
	camera.fov = BASE_FOV;
	default_camera_orientation = camera_pivot.rotation;
	ball.body_entered.connect(_on_hit_ground);

func _process(_delta: float) -> void:
	# Reset camera's (parent) position to follow ball.
	camera_pivot.global_position = ball.global_position;

func _physics_process(delta: float) -> void:
	Globals.visualizer(delta, mesh, "material_override:emission_energy_multiplier", 2, 4, 2, 2.5);
	if not Globals.is_game_started: return;
	# Store the previous frame's velocity for calulating velocity on impacts.
	last_frames_velocity = ball.linear_velocity;
	
	# Set "forward" to be direction camera is facing.
	forward = camera.global_transform.basis.z.normalized().cross(Vector3.UP);
	
	# Limit ball velocities.
	ball.linear_velocity.x = clampf(ball.linear_velocity.x, -MAX_SPEED, MAX_SPEED);
	ball.linear_velocity.y = clampf(ball.linear_velocity.y, -50, 50);
	ball.linear_velocity.z = clampf(ball.linear_velocity.z, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.x = clampf(ball.angular_velocity.x, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.y = clampf(ball.angular_velocity.y, -MAX_SPEED, MAX_SPEED);
	ball.angular_velocity.z = clampf(ball.angular_velocity.z, -MAX_SPEED, MAX_SPEED);
	handle_input();
	offset_camera();
	
	if ball.global_position.y < -40: ball.global_position = Vector3(0, 10, 0);

func _input(event: InputEvent) -> void:
	if not Globals.is_game_started: return;
	
	# If key is tapped, not held, reset camera rotation.
	if Input.is_action_just_pressed("rotate_camera"):
		await get_tree().create_timer(0.15).timeout;
		if not Input.is_action_pressed("rotate_camera"):
			reset_camera();
	
	# Rotate the camera if key is held and mouse is in motion.
	if event is InputEventMouseMotion:
		var invert = 1 if Globals.is_look_inverted else -1;
		camera_pivot.rotate(Vector3(0,1,0), invert * event.relative.x * camera.camera_rotation_speed * Globals.camera_sensitivity_setting);

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
		if ball.linear_velocity.y > 0: ball.linear_velocity.y = 0;
		ball.apply_central_force(Vector3(0, -SLAM_FORCE, 0));
		ball.linear_velocity.y = clampf(ball.linear_velocity.y, -MAX_SPEED*2, MAX_SPEED*2);

## Helper function to reset camera orientation.
func reset_camera() -> void:
	var tween = get_tree().create_tween();
	tween.tween_property(camera_pivot, "rotation", default_camera_orientation, 0.15);

## Dynamically offset the camera to "trail" based on horizontal speeds.
func offset_camera() -> void:
	if not (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		if camera.h_offset < 0: camera.h_offset += 0.01;
		elif camera.h_offset > 0: camera.h_offset -= 0.01;
		if abs(camera.h_offset) < 0.05: camera.h_offset = 0;
		return;
	var x = -ball.linear_velocity.dot(camera.global_basis.x)/1500;
	camera.h_offset += x;
	camera.h_offset = clampf(camera.h_offset, -0.5, 0.5);

func set_emission(color: Color) -> void:
	mesh.material_override.emission = color;
	ball_light.light_color = color;

func _on_hit_ground(body: Node3D) -> void:
	if body is not GridMap: return;
	if last_frames_velocity.y < -8:
		camera._camera_shake(0.1, 0.075);
		#Globals.freeze_frame(0.4, 0.25);
