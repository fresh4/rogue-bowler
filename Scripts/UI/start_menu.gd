extends Control

# If in the scene, this will cause it to auto show on load.
@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton

const PAUSE_MENU = preload("res://Scenes/pause_menu.tscn")

var level_manager: LevelManager;
var pause_menu: Control;

func _ready() -> void:
	# Make this scene visible.
	visible = true;
	level_manager = get_parent().get_parent();
	start_button.pressed.connect(_on_start_button_pressed);
	settings_button.pressed.connect(_on_settings_button_pressed);
	pause_menu = PAUSE_MENU.instantiate();
	add_child(pause_menu);
	pause_menu.visible = false;

func _input(_event: InputEvent) -> void:
	if Globals.is_game_started: return;
	if Input.is_action_just_pressed("pause"):
		pause_menu.visible = false;

func _on_start_button_pressed() -> void:
	var tween = get_tree().create_tween();
	tween.tween_property(self, "modulate", Color(1,1,1,0), 1);
	await tween.finished;
	
	# TODO: Bandaid, put this elsewhere.
	fade_track(AudioManager.LAYERS.MENU_TRACK, -60, 3);
	fade_track(AudioManager.LAYERS.BASE_TRACK_DUCKED, 0, 1);
	
	visible = false;
	modulate = Color(1,1,1,1);
	level_manager.start_game();
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	pause_menu.queue_free();
	queue_free();

func fade_track(idx, vol, t) -> void:
	var cur_vol = AudioManager.game_music_player.stream.get_sync_stream_volume(idx);
	var callback = func(value): AudioManager.game_music_player.stream.set_sync_stream_volume(idx, value);
	var tween = get_tree().create_tween();
	tween.tween_method(callback, cur_vol, vol, t);

func _on_settings_button_pressed() -> void:
	pause_menu.visible = !pause_menu.visible;
