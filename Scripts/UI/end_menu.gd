extends Control

@onready var replay_button: Button = %ReplayButton
@onready var score_label: Label = %ScoreLabel

var level_manager: LevelManager;

func _ready() -> void:
	#get_tree().paused = true;
	level_manager = get_tree().get_first_node_in_group("LevelManager") as LevelManager;
	level_manager.g_timer.paused = true;
	replay_button.pressed.connect(_on_replay_button_pressed);
	score_label.text = str(0);
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	
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

func update_score(value: int) -> void:
	score_label.text = str(value);

func _on_replay_button_pressed() -> void:
	get_tree().reload_current_scene();
