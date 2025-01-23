class_name LevelManager extends Node3D

signal score_updated(score);
signal timer_started(time);
signal combo_updated(value);

@export var player: Player;

@export var COMBO_TIMER_S: float = 3.0; ## How long to wait before considering a throw "complete"

@onready var world_environment: WorldEnvironment = %WorldEnvironment

var score: int = 0; ## Total effective score
var throws: int = 0; ## How many times the ball was "thrown" (hit a pin within a time frame)
var pins: Array[Pin] = []; ## All pins on the field on level load
var knocked_pins: Array[Pin] = []; ## All pins that have been knocked over to avoid count if hit again
var combo_pins: Array[Pin] = []; ## All the pins hit within a certain time frame of each other
var timer: Timer = Timer.new();

var ball: RigidBody3D = null;
var camera: CustomCamera = null;

func _ready() -> void:
	ball = player.get_node("%Ball");
	camera = player.get_node("%Camera");
	
	ball.body_entered.connect(_on_ball_hit_pins);
	
	# Set up score timer data.
	timer.one_shot = true;
	timer.wait_time = COMBO_TIMER_S;
	add_child(timer);
	
	# Keep track of pins placed in the scene.
	var detected_pins = get_tree().get_nodes_in_group("Pins");
	for obj in detected_pins:
		if obj is Pin:
			pins.append(obj);
			obj.pin_knocked_over.connect(_on_pin_knocked_over.bind(obj));

func _physics_process(delta: float) -> void:
	horizon_beat_visualizer(delta);

func horizon_beat_visualizer(delta: float) -> void:
	if Globals.is_visualizer_disabled: return
	if not AudioManager.game_music_player.playing: return;
	var spectrum: AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(1,0);
	var volume = spectrum.get_magnitude_for_frequency_range(100, 250).length();
	var bg_energy: float = world_environment.environment.background_energy_multiplier;
	if bg_energy > 1:
		bg_energy -= delta*2;
	elif bg_energy < 2 and volume > 0.3:
		bg_energy = 5 * volume;
	world_environment.environment.background_energy_multiplier = clampf(bg_energy, 0.1, 1.65);

func _on_ball_hit_pins(body: Node3D) -> void:
	if not body is Pin: return;
	body = body as Pin;
	
	camera._camera_shake(0.1, 0.1);
	
	if body.is_knocked: return;
	
	Globals.freeze_frame(0.35, 0.5);
	
	if timer.is_stopped(): 
		timer.start();
		timer_started.emit(timer.wait_time);
		await timer.timeout;
		score += len(combo_pins);
		score_updated.emit(score);
		
		combo_pins = [];
		await get_tree().create_timer(2).timeout;
		if len(combo_pins) == 0:
			combo_updated.emit(0);
	else: 
		return;

func _on_pin_knocked_over(pin: Pin) -> void:
	if pin not in knocked_pins:
		knocked_pins.append(pin);
	if pin not in combo_pins:
		combo_pins.append(pin);
		combo_updated.emit(len(combo_pins));
