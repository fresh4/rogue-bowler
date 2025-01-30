class_name Pin extends RigidBody3D

signal pin_knocked_over;

@onready var mesh: MeshInstance3D = %Mesh
@onready var audio_player: AudioStreamPlayer3D = %AudioPlayer

var is_knocked: bool = false;

func _physics_process(_delta: float) -> void:
	if not is_knocked and check_knocked():
		pin_knocked_over.emit();
		is_knocked = true;

func check_knocked() -> bool:
	return abs(rotation_degrees.x) > 45 or abs(rotation_degrees.z) > 45;

func set_pin_color(value: Color) -> void:
	mesh.material_override.emission = value;

func _on_body_entered(body: Node) -> void:
	if not (body is Player or body is Pin): return;
	if body is Pin and is_knocked: return;
	AudioManager.play_random(AudioManager.PIN_IMPACTS, audio_player);
