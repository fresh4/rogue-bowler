extends AudioStreamPlayer

var level_manager: LevelManager;
var player: Player;

func _ready() -> void:
	level_manager = get_tree().get_first_node_in_group("LevelManager") as LevelManager;
	player = level_manager.player;

func _process(_delta: float) -> void:
	handle_conditional_music();

func handle_conditional_music() -> void:
	## Handle volume for the velocity conditional audio tracks.
	var v = player.ball.linear_velocity.length();
	var velocity_volume: float = -60;
	if v < 5: velocity_volume = -60;
	elif v < 10: velocity_volume = -30;
	elif v < 15: velocity_volume = -20;
	elif v < 20: velocity_volume = -10;
	elif v < 25: velocity_volume = -5;
	elif v >= 25: velocity_volume = 0;
	AudioManager.game_music_player.stream.set_sync_stream_volume(AudioManager.LAYERS.SPEED_TRACK, velocity_volume);
	
	## Handle volume for the progress conditional audio tracks.
	var progress_volume: float = -60;
	var f = level_manager.current_frame + 1;
	if f < 3: progress_volume = -60;
	elif f < 5: progress_volume = -20;
	elif f < 8: progress_volume = -10;
	else: progress_volume = 0;
	AudioManager.game_music_player.stream.set_sync_stream_volume(AudioManager.LAYERS.PROGRESS_TRACK, progress_volume);
