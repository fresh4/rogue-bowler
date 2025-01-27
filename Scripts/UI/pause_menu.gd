extends Control

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var invert_look_toggle: CheckButton = %InvertLookToggle
@onready var bg: ColorRect = %BG
@onready var visualizer_toggle: CheckButton = %VisualizerToggle
@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var back_button: Button = %BackButton

var is_paused: bool = false;

func _ready() -> void:
	visible = false;
	
	# Connect UI events to local functions.
	invert_look_toggle.pressed.connect(_on_toggle_invert_look);
	visualizer_toggle.pressed.connect(_on_toggle_visualizer);
	sfx_slider.value_changed.connect(_on_sfx_slider_changed);
	music_slider.value_changed.connect(_on_music_slider_changed);
	sensitivity_slider.value_changed.connect(_on_sensitivity_slider_changed);
	back_button.pressed.connect(_on_back_button_pressed);
	
	# Set default settings and sync with slider values
	music_slider.value = 0.5;
	music_slider.value_changed.emit(music_slider.value);
	
	sfx_slider.value = 0.5;
	sfx_slider.value_changed.emit(sfx_slider.value);
	
	sensitivity_slider.value = 0.5;
	sensitivity_slider.value_changed.emit(sensitivity_slider.value);

func _input(event: InputEvent) -> void:
	if not Globals.is_game_started: return;
	if event is InputEventMouseButton:
		if !is_paused and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_just_pressed("pause"):
		if is_paused: unpause();
		else: pause();

func _on_toggle_invert_look():
	Globals.is_look_inverted = !Globals.is_look_inverted;

func _on_toggle_visualizer():
	Globals.is_visualizer_disabled = !Globals.is_visualizer_disabled;

func _on_music_slider_changed(value):
	AudioManager.set_volume("Music", value);

func _on_sfx_slider_changed(value):
	AudioManager.set_volume("SFX", value);

func _on_sensitivity_slider_changed(value):
	Globals.camera_sensitivity_setting = value;

func _on_back_button_pressed():
	if Globals.is_game_started:
		unpause();
	else:
		visible = false;

func pause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	is_paused = true;
	
	bg.color.a = 0;
	var tween = get_tree().create_tween();
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS);
	tween.tween_property(bg, "color:a", 0.75, 0.25);
	get_tree().paused = is_paused;
	visible = true;

func unpause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	is_paused = false;
	get_tree().paused = is_paused;
	bg.color.a = 0;
	visible = false;
