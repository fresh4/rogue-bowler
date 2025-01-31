extends Node

enum LAYERS {BASE_TRACK, BASE_TRACK_DUCKED, KICK_TRACK, PERC_TRACK, MENU_TRACK};

const MUSIC_PLAYER = preload("res://Prefabs/music_player.tscn");

#region Audio Imports
const PIN_HIT_1 = preload("res://Assets/Audio/SFX/pin_hit_1.ogg")
const PIN_HIT_2 = preload("res://Assets/Audio/SFX/pin_hit_2.ogg")
const PIN_HIT_3 = preload("res://Assets/Audio/SFX/pin_hit_3.ogg")
const PIN_HIT_4 = preload("res://Assets/Audio/SFX/pin_hit_4.ogg")
const PIN_HIT_5 = preload("res://Assets/Audio/SFX/pin_hit_5.ogg")
const PIN_HIT_6 = preload("res://Assets/Audio/SFX/pin_hit_6.ogg")
const PIN_HIT_7 = preload("res://Assets/Audio/SFX/pin_hit_7.ogg")

const BALL_IMPACT_PINS = preload("res://Assets/Audio/SFX/ball-impact-pins.ogg")
const POWERUP_PICKUP = preload("res://Assets/Audio/SFX/powerup pickup.ogg")
const BASS_IMPACT = preload("res://Assets/Audio/SFX/bass impact.ogg")
const IMPACT_TONE = preload("res://Assets/Audio/SFX/impact-tone.ogg")

const PIN_IMPACTS: Array[AudioStream] = [
	PIN_HIT_1, PIN_HIT_2, PIN_HIT_3, PIN_HIT_4, PIN_HIT_5, PIN_HIT_6, PIN_HIT_7
]
#endregion

var music_volume: float = 0.5;
var sfx_volume: float = 0.5;

var menu_music_player: AudioStreamPlayer;
var game_music_player: AudioStreamPlayer;

var current_player: AudioStreamPlayer = null;
var tween: Tween;

func _ready() -> void:
	game_music_player = MUSIC_PLAYER.instantiate() as AudioStreamPlayer;
	game_music_player.bus = "Music";
	
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
	add_child(game_music_player);
	game_music_player.play();

func initialize_player(stream: Resource) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new();
	player.bus = "Music";
	player.stream = stream;
	player.volume_db = -72;
	player.autoplay = true;
	#player.stream_paused = true
	add_child(player);
	return player;

func crossfade(new_player: AudioStreamPlayer, fade_in_t: float = 1, fade_out_t: float = 1) -> void:
	# Accept a new music player to start playing
	# Fade out the current player
	# Fade in the new player
	if new_player == current_player: return;
	tween = get_tree().create_tween().set_parallel();
	#new_player.stream_paused = false
	tween.tween_property(current_player, "volume_db", -72, fade_out_t);
	tween.tween_property(new_player, "volume_db", 0, fade_in_t);
	await tween.finished;
	current_player = new_player;
	#current_player.stream_paused = true

func play(player: AudioStreamPlayer, fade_in_t: float = 1) -> void:
	# Start an existing audio player
	# Does not add to or overwrite the main 'current player'
	# Only meant to play atop existing elements.
	var play_tween = get_tree().create_tween();
	#player.stream_paused = false
	play_tween.tween_property(player, "volume_db", 0, fade_in_t);

func stop(player: AudioStreamPlayer, fade_out_t: float = 1) -> void:
	# Stop a specific existing audio player
	var stop_tween = get_tree().create_tween();
	stop_tween.tween_property(player, "volume_db", -72, fade_out_t);
	await stop_tween.finished;
	#player.stream_paused = true

func set_volume(mixer: String, volume: float) -> float:
	var bus_idx = AudioServer.get_bus_index(mixer);
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume));
	return volume;

func play_audio(file: AudioStream, mixer: String = "SFX", volume: float = 1) -> void:
	# given a preloaded soundfile, generate an audio stream player, spawn it
	# load the file, play it, and then destroy the player.
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new();
	audio_player.stream = file;
	audio_player.bus = mixer;
	audio_player.volume_db = linear_to_db(volume);
	add_child(audio_player);
	audio_player.play();
	await audio_player.finished;
	remove_child(audio_player);
	audio_player.queue_free();

func play_random(list: Array[AudioStream], player: AudioStreamPlayer3D = null) -> void:
	var track = list.pick_random();
	if player:
		player.stream = track;
		player.play();
	else:
		play_audio(track);

func fade_track(idx, vol, t) -> void:
	var cur_vol = game_music_player.stream.get_sync_stream_volume(idx);
	var callback = func(value): game_music_player.stream.set_sync_stream_volume(idx, value);
	var tween_2 = get_tree().create_tween();
	tween_2.tween_method(callback, cur_vol, vol, t);

#func on_scene_changed() -> void:
	## Automatically handle audio shifting based on the current scene
	#if tween and tween.is_running():
		#await tween.finished
	#
	#if get_tree().current_scene.name == "MainMenu":
		#await crossfade(menu_music_player, 0.25, 2)
	#else:
		#await crossfade(game_music_player, 0.25, 2)
