@tool
extends PowerUp

@export var timer: int = 15;

func activate(_body) -> void:
	var time_left = level_manager.g_timer.time_left + timer;
	level_manager.g_timer.wait_time = time_left;
	level_manager.g_timer.start(time_left);
	queue_free();
