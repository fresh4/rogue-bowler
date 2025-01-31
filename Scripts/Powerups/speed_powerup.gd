@tool
extends PowerUp

var base_speed;
var base_acc;

func activate(_body: RigidBody3D) -> void:
	visible = false; 
	detection_area.set_deferred("monitoring", false);
	base_speed = player.MAX_SPEED;
	base_acc = player.ACC_RATE;
	
	player.ACC_RATE = 100;
	player.MAX_SPEED = 100;
	
	await get_tree().create_timer(5).timeout;
	
	player.ACC_RATE = base_acc;
	player.MAX_SPEED = base_speed;
	
	queue_free();
