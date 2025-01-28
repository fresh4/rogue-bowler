extends Control

@onready var replay_button: Button = %ReplayButton
@onready var score_label: Label = %ScoreLabel
@onready var timebonus: Label = %TIMEBONUS
@onready var time_label: Label = %TimeLabel

var level_manager: LevelManager;

func _ready() -> void:
	level_manager = get_tree().get_first_node_in_group("LevelManager") as LevelManager;
	level_manager.g_timer.paused = true;
	replay_button.pressed.connect(_on_replay_button_pressed);
	score_label.text = str(0);
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	
	var total_score: int = level_manager.total_score;
	var time_left: int = int(level_manager.g_timer.time_left);
	
	# Fade the element in on load.
	modulate.a = 0;
	visible = true;
	var tween = get_tree().create_tween();
	tween.tween_property(self, "modulate", Color(1,1,1,1), 1);
	await tween.finished;
	
	# On scene load, score starts at 0 and increments to final actual score.
	await get_tree().create_timer(1).timeout;
	tween = get_tree().create_tween();
	tween.tween_method(update_score, 0, level_manager.total_score, 3).set_ease(Tween.EASE_IN_OUT);
	await tween.finished;
	
	# Apply the timer score with a short animation.
	await get_tree().create_timer(0.5).timeout;
	timebonus.visible = true;
	
	await get_tree().create_timer(0.5).timeout;
	time_label.visible = true;
	time_label.text = str(time_left);
	
	await get_tree().create_timer(0.5).timeout;
	var tween_timer = get_tree().create_tween().set_parallel(true);
	var tween_score = get_tree().create_tween().set_parallel(true);
	tween_timer.tween_method(update_time, time_left, 0, 2);
	tween_score.tween_method(update_score, total_score, total_score + time_left, 2);

func update_time(value: int) -> void:
	time_label.text = str(value);

func update_score(value: int) -> void:
	score_label.text = str(value);

func _on_replay_button_pressed() -> void:
	get_tree().reload_current_scene();
