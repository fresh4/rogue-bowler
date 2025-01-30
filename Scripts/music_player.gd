extends AudioStreamPlayer

enum LAYERS {BASE_TRACK, BASE_TRACK_DUCKED, KICK_TRACK, PERC_TRACK };

var level_manager: LevelManager;
var player: Player;
#var min_kick_speed: float = 

func _ready() -> void:
	level_manager = get_tree().get_first_node_in_group("LevelManager") as LevelManager;
	player = level_manager.player;

func _process(_delta: float) -> void:
	handle_conditional_music();

func handle_conditional_music() -> void:
	## Handle volume for the velocity conditional audio tracks.
	var v = player.ball.linear_velocity.length();
	var kick_volume: float = linear_to_db(clampf(v/20, 0, 1));
	var perc_volume: float = linear_to_db(clampf(v/30, 0, 1));
	var duck_volume: float = linear_to_db(clampf(v/5, 0, 1));
	var noduck_volume: float =  linear_to_db(1 - clampf(v/5, 0, 1));
	
	AudioManager.game_music_player.stream.set_sync_stream_volume(LAYERS.BASE_TRACK_DUCKED, duck_volume);
	AudioManager.game_music_player.stream.set_sync_stream_volume(LAYERS.BASE_TRACK, noduck_volume);
	AudioManager.game_music_player.stream.set_sync_stream_volume(LAYERS.KICK_TRACK, kick_volume);
	AudioManager.game_music_player.stream.set_sync_stream_volume(LAYERS.PERC_TRACK, perc_volume);
		
func speed_to_volume(speed, max_speed=30, min_volume=-60, max_volume=0) -> float:
	return clampf(min_volume + (max_volume - min_volume) * (speed / max_speed), min_volume, max_volume);
