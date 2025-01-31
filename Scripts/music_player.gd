extends AudioStreamPlayer

var level_manager: LevelManager;
var player: Player;
var is_fading: bool = false;

func _ready() -> void:
	init()

func init():
	level_manager = get_tree().get_first_node_in_group("LevelManager") as LevelManager;
	player = level_manager.player;

func _process(_delta: float) -> void:
	handle_conditional_music();

func handle_conditional_music() -> void:
	## Handle volume for the velocity conditional audio tracks.
	if not player: init();
	var v = player.ball.linear_velocity.length();
	var kick_volume: float = linear_to_db(clampf(v/20, 0, 1));
	var perc_volume: float = linear_to_db(clampf(v/30, 0, 1));
	
	set_stream_volume(AudioManager.LAYERS.KICK_TRACK, kick_volume);
	set_stream_volume(AudioManager.LAYERS.PERC_TRACK, perc_volume);
	
	# TODO: Should handle the logic for setting the ducking tracks but no time, basing it on paused.

func set_stream_volume(idx, vol) -> void:
	AudioManager.game_music_player.stream.set_sync_stream_volume(idx, vol);
