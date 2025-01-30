@tool
extends PowerUp

func activate(body: RigidBody3D) -> void:
	queue_free();
	
	var player = body.get_parent() as Player;
	var default_acc_rate = player.ACC_RATE;
	
	player.ACC_RATE = 100;
	player.MAX_SPEED = 100;
	player.ball.linear_velocity.y = 50;
	await get_tree().create_timer(5).timeout;
	
	player.ACC_RATE = default_acc_rate;
	
