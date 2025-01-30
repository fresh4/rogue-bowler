extends Control

@export var show_fps: bool = false;

@onready var score_value: Label = %ScoreValue;
@onready var combo_value: Label = %ComboValue;
@onready var timer_slider: ProgressBar = %TimerSlider;
@onready var game_timer_label: Label = %GameTimerLabel;
@onready var fps: Label = %FPS;
@onready var scorecard_rows: VBoxContainer = %ScorecardRows

const FRAME = preload("res://Prefabs/frame.tscn");
const END_MENU = preload("res://Scenes/end_menu.tscn");

var level_manager: LevelManager = null;
var timer_length: float = 0;
var frames: Array[Frame] = [];

var combo_arr = ["Hit Something!", "Single", "Double", "Triple", "Quad!", "Penta!", "SEXTUPLE!", "SEPTOUPLE!", "OCTOUPLE!", "NINER!", "STRIKE!!!"];

func _ready() -> void:
	visible = false;
	level_manager = get_parent().get_parent();
	
	level_manager.score_updated.connect(update_score);
	level_manager.combo_updated.connect(update_combo);
	level_manager.timer_started.connect(start_timer_bar);
	level_manager.frame_updated.connect(update_frames);
	level_manager.game_ended.connect(end_game);
	
	score_value.text = str(0);
	combo_value.text = combo_arr[0];
	timer_slider.visible = false;
	fps.visible = show_fps;
	
	for i in range(10):
		var frame_obj = FRAME.instantiate();
		scorecard_rows.add_child(frame_obj);
		frames.append(frame_obj);

func _process(_delta: float) -> void:
	if Globals.is_game_started and not visible: visible = true;
	update_game_timer();
	if show_fps: fps.text = str(Engine.get_frames_per_second());

func update_score(score: int) -> void:
	score_value.text = str(score);

func update_combo(value) -> void:
	combo_value.text = combo_arr[ clamp( value, 0, len(combo_arr) - 1 ) ];

func update_frames(value: Array) -> void:
	var i = level_manager.current_frame;
	frames[i].fill_frame(value);

func start_timer_bar(wait_time: float) -> void:
	timer_length = wait_time;
	timer_slider.value = 0;
	timer_slider.visible = true;
	
	var tween = get_tree().create_tween();
	tween.tween_property(timer_slider, "value", 100, wait_time);
	await tween.finished;
	timer_slider.visible = false;

func update_game_timer() -> void:
	var game_time_s: int = int(level_manager.g_timer.time_left) % 60;
	var game_time_m: int = int(level_manager.g_timer.time_left / 60);
	
	game_timer_label.text = "%02d:%02d" % [game_time_m, game_time_s]

func end_game() -> void:
	Globals.is_game_started = false;
	
	var TIMER: int = 1;
	var end_menu = END_MENU.instantiate();
	Globals.freeze_frame(0.4, TIMER+2);
	await get_tree().create_timer(TIMER).timeout;
	get_parent().add_child(end_menu);
