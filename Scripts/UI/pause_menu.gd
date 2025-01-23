extends Control

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var invert_look_toggle: CheckButton = %InvertLookToggle
@onready var bg: ColorRect = %BG
@onready var visualizer_toggle: CheckButton = %VisualizerToggle

var is_paused: bool = false;

func _ready() -> void:
	visible = false;
	invert_look_toggle.pressed.connect(_on_toggle_invert_look);
	visualizer_toggle.pressed.connect(_on_toggle_visualizer);
	sfx_slider.value_changed.connect(_on_sfx_slider_changed);
	music_slider.value_changed.connect(_on_music_slider_changed);
	
	music_slider.value = 0.5; # TODO: Get the existing value for the music player
	sfx_slider.value = 0.5; # TODO: Get the existing value for the sfx player
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if is_paused: unpause();
		else: pause();
		
		get_tree().paused = is_paused;
		visible = is_paused;

func _on_toggle_invert_look():
	Globals.is_look_inverted = !Globals.is_look_inverted;

func _on_toggle_visualizer():
	Globals.is_visualizer_disabled = !Globals.is_visualizer_disabled;

func _on_music_slider_changed(value):
	AudioManager.set_volume("Music", value);

func _on_sfx_slider_changed(value):
	AudioManager.set_volume("SFX", value);

func pause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	is_paused = true;
	
	var tween = get_tree().create_tween();
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property(bg, "color:a", 0.35, 0.25);

func unpause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	is_paused = false;
	bg.color.a = 0;
