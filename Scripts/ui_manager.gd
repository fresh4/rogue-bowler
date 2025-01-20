extends CanvasLayer

@onready var score_value: Label = %ScoreValue
@onready var combo_value: Label = %ComboValue
@onready var timer_slider: ProgressBar = %TimerSlider

var level_manager: LevelManager = null;
var timer_length: float = 0;

var combo_arr = ["Hit Something!", "Single", "Double", "Triple", "Quad!", "Penta!", "SEXTUPLE!", "SEPTOUPLE!", "OCTOUPLE!", "NINER!", "STRIKE!!!"];

func _ready() -> void:
	level_manager = get_parent();
	
	level_manager.score_updated.connect(update_score);
	level_manager.combo_updated.connect(update_combo);
	level_manager.timer_started.connect(start_timer_bar);
	
	score_value.text = str(0);
	combo_value.text = combo_arr[0];
	timer_slider.visible = false;

func update_score(score: int) -> void:
	score_value.text = str(score);

func update_combo(value) -> void:
	combo_value.text = combo_arr[ clamp( value, 0, len(combo_arr) - 1 ) ];

func start_timer_bar(wait_time: float) -> void:
	timer_length = wait_time;
	timer_slider.value = 0;
	timer_slider.visible = true;
	
	var tween = get_tree().create_tween();
	tween.tween_property(timer_slider, "value", 100, wait_time);
	await tween.finished;
	timer_slider.visible = false;
