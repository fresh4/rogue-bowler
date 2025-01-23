class_name Pin extends RigidBody3D

signal pin_knocked_over;

@onready var mesh: MeshInstance3D = %Mesh

var is_knocked: bool = false;
var color: Color;

#func _ready() -> void:
	#mesh.material_override.emission = Color(randf(), randf(), randf(), 1.0);

func _physics_process(_delta: float) -> void:
	if not is_knocked and check_knocked():
		pin_knocked_over.emit();
		is_knocked = true;

func check_knocked() -> bool:
	return abs(rotation_degrees.x) > 45 or abs(rotation_degrees.z) > 45;

func set_pin_color(c: Color) -> void:
	color = c;
	mesh.material_override.emission = c;
