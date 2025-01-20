class_name Pin extends RigidBody3D

signal pin_knocked_over;

var is_knocked: bool = false;

func _physics_process(_delta: float) -> void:
	if not is_knocked and check_knocked():
		pin_knocked_over.emit();
		is_knocked = true;

func check_knocked() -> bool:
	return abs(rotation_degrees.x) > 45 or abs(rotation_degrees.z) > 45;
