class_name CustomCamera extends Camera3D

@export var period: float = 0.3;
@export var magnitude: float = 0.4;
@export var camera_rotation_speed: float = 0.01;

func _camera_shake(p: float = period, m: float = magnitude):
	var initial_transform = self.transform ;
	var elapsed_time = 0.0;

	while elapsed_time < p:
		var offset = Vector3(
			randf_range(-m, m),
			randf_range(-m, m),
			0.0
		);

		self.transform.origin = initial_transform.origin + offset;
		elapsed_time += get_process_delta_time();
		await get_tree().process_frame;

	self.transform = initial_transform;
