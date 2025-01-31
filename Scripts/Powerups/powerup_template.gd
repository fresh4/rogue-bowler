@tool
class_name PowerUp extends Node3D

# This class is a virtual class with some basic functionality, and holds default variables.
# Do not attach this script to any scripts. Instead, make a new script that extends this class.
# Override the "activate" function to apply custom logic on interaction with your "powerup".

signal selection_changed;

@export var is_rotate: bool = true;
@export var detection_area: Area3D;
@export var mesh: MeshInstance3D;

@export_enum("PINK", "CYAN", "WHITE") var selected_color: String :
	set(value): selected_color = value; _on_selection_changed();


func _ready() -> void:
	selection_changed.connect(_on_selection_changed);
	detection_area.body_entered.connect(activate);
	detection_area.body_entered.connect(global_activate);
	
	detection_area.set_collision_mask_value(2, true);
	detection_area.set_collision_mask_value(1, false);
	_on_selection_changed();

func _physics_process(delta: float) -> void:
	if not is_rotate: return;
	rotation.y += delta * 5;
	var rot = rad_to_deg(rotation.y)
	if rot >= 360: rotation.y = deg_to_rad(360) - rotation.y;

func activate(_body: RigidBody3D) -> void:
	# Override this in extended class
	pass

func global_activate(_body: RigidBody3D) -> void:
	# Do NOT override unless necessary
	AudioManager.play_audio(AudioManager.POWERUP_PICKUP);

func _on_selection_changed() -> void:
	if not mesh or not mesh.material_override: return;
	mesh.material_override.albedo_color = Globals.get(selected_color);
	mesh.material_override.emission = Globals.get(selected_color);
