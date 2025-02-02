class_name LevelManager extends Node3D

signal score_updated(score);
signal timer_started(time);
signal combo_updated(value);
signal frame_updated(value);
signal game_ended();

@export var player: Player;

@export var COMBO_TIMER_S: float = 3.0; ## How long to wait before considering a throw "complete"
@export var GAME_TIMER_S: float = 300.0; ## How long to wait before considering a throw "complete"

@onready var world_environment: WorldEnvironment = %WorldEnvironment;

const MAX_THROWS = 10;

var total_score: int = 0 ## Total effective score.
var score: int = 0; ## Total score for a given frame. Resets each progressed frame.
var current_throw: int = 0; ## How many times the ball was "thrown" (hit a pin within a time frame)
var current_frame: int = 0; ## Which frame (out of 10) we're on
var frame_scores_list: Array[Array] = []; ## A list of arrays, each of max length 2.
var frame_display_list: Array[Array] = []; ## Similar to frame_scores, but is the text shown on screen.

var pins: Array[Pin] = []; ## All pins on the field on level load
var knocked_pins: Array[Pin] = []; ## All pins that have been knocked over to avoid count if hit again
var combo_pins: Array[Pin] = []; ## All the pins hit within a certain time frame of each other
var c_timer: Timer = Timer.new(); ## Combo timer to determine the start and end of a throw
var g_timer: Timer = Timer.new(); ## Game timer to determine final score
var is_freeze_framed: bool = false;

var ball: RigidBody3D = null;
var camera: CustomCamera = null;

func _ready() -> void:
	world_environment.environment.fog_enabled = true;
	ball = player.get_node("%Ball");
	camera = player.get_node("%Camera");
	
	ball.body_entered.connect(_on_ball_hit_pins);
	g_timer.timeout.connect(game_ended.emit);
	
	# Init frames
	for i in range(10):
		frame_scores_list.append([0,0]);
		frame_display_list.append(["",""]);
	
	# Set up score timer data.
	c_timer.one_shot = true;
	c_timer.wait_time = COMBO_TIMER_S;
	add_child(c_timer);
	
	# Set up game timer data.
	g_timer.one_shot = true;
	g_timer.wait_time = GAME_TIMER_S;
	add_child(g_timer);

func _physics_process(delta: float) -> void:
	Globals.visualizer(delta, world_environment, "environment:background_energy_multiplier", 1, 2, 0.1, 1.65);

func start_game() -> void:
	player.animator.play("Start");
	await player.animator.animation_finished;
	Globals.is_game_started = true;
	g_timer.start();

func _on_ball_hit_pins(body: Node3D) -> void:
	if not body is Pin: return;
	body = body as Pin;
	
	camera._camera_shake(0.1, ball.linear_velocity.length() * 0.008);
	
	if body.is_knocked: return;
	
	AudioManager.play_audio(AudioManager.BALL_IMPACT_PINS);
	#AudioManager.play_audio(AudioManager.BASS_IMPACT);
	AudioManager.play_audio(AudioManager.IMPACT_TONE);
	
	if not is_freeze_framed:
		Globals.freeze_frame(0.35, 0.5);
		is_freeze_framed = true;
	
	camera._camera_shake(0.1, 0.1);
	
	# Pin is hit, start a timer. All pins hit within that timeframe count towards
	# the score of that "throw".
	if c_timer.is_stopped():
		is_freeze_framed = false;
		c_timer.start();
		timer_started.emit(c_timer.wait_time);
		await c_timer.timeout;
		calculate_score();
		score_updated.emit(total_score);
		c_timer.wait_time = COMBO_TIMER_S;
		
		combo_pins = [];
		await get_tree().create_timer(2).timeout;
		if len(combo_pins) == 0:
			combo_updated.emit(0);
	else: 
		return;

func calculate_score() -> void:
	var frame_score: int = len(combo_pins); # Number of pins knocked over this throw.
	score += frame_score; # Counts the TOTAL knocked over pins this frame.
	total_score += frame_score; # Adds to the global game score. TODO: Maybe change.
	current_throw += 1; # Increment the throw; a frame consists of (max) two throws.
	
	# Skip to next frame if strike.
	if current_throw == 1 and score >= 10:
		update_frames(10, "X");
		progress_to_next_frame();
		return;
	
	# We hit a spare! Progress to next frame.
	if current_throw == 2 and score >= 10:
		update_frames(frame_score, "/");
		progress_to_next_frame();
		return;
	
	# Progress to next frame if we've made two throws this frame, regardless of final score.
	if current_throw >= 2:
		update_frames(frame_score);
		progress_to_next_frame();
		return;
	
	# Currently only made one throw. Add score and continue this frame.
	if current_throw < 2 and score < 10:
		update_frames(frame_score);
		return;

func update_frames(value: int, value2: String = str(value)) -> void:
	frame_scores_list[current_frame][current_throw - 1] = (value);
	frame_display_list[current_frame][current_throw - 1] = str(value2);
	frame_updated.emit(frame_display_list[current_frame]);
	#print("RAW SCORES: ", frame_scores_list, " DISPLAYED SCORES: ", frame_display_list);

func progress_to_next_frame() -> void:
		current_frame += 1; 
		current_throw = 0;
		score = 0;
		if current_frame >= MAX_THROWS and Globals.is_game_started:
			game_ended.emit();

func _on_pin_knocked_over(pin: Pin) -> void:
	AudioManager.play_random(AudioManager.PIN_IMPACTS, pin.audio_player);
	if c_timer.is_stopped(): return; # TODO: Confirm if helps
	if pin not in knocked_pins:
		knocked_pins.append(pin);
	if pin not in combo_pins:
		combo_pins.append(pin);
		combo_updated.emit(len(combo_pins));
