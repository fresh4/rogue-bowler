extends Node

var is_look_inverted: bool = false;
var is_visualizer_disabled: bool = false;
var camera_sensitivity_setting: float = 1;

func freeze_frame(timescale: float, duration: float) -> void:
	# Function that 'stops' time for a very brief moment.
	# Timescale is how slow you want the game to run (0.5 for half speed etc)
	# Duration is how long you want it to remain that way
	# Note that timescale must be > 0, as time will never resume if the engine has stopped counting
	Engine.time_scale = timescale;
	await get_tree().create_timer(duration * timescale).timeout;
	Engine.time_scale = 1.0;
