class_name LevelManager extends Node3D

# TODO:
# Have a score tracker
# Track pins in the level on startup
# Track knocked down pins
# On hit, start a timer; any pins knocked over in that time are counted to a combo
# 10+ combo = strike, etc.

signal score_updated(score);
signal timer_started(time);
signal combo_updated(value);

@export var player: Player;

const TIMER_S: float = 3.0;

var score: int = 0;
var throws: int = 0;
var pins: Array[Pin] = [];
var knocked_pins: Array[Pin] = [];
var combo_pins: Array[Pin] = [];
var timer: Timer = Timer.new();

var ball: RigidBody3D = null;
var camera: CustomCamera = null;

func _ready() -> void:
	ball = player.get_node("%Ball");
	camera = player.get_node("%Camera");
	
	ball.body_entered.connect(_on_ball_hit_pins);
	
	# Set up score timer data.
	timer.one_shot = true;
	timer.wait_time = TIMER_S;
	add_child(timer);
	
	# Keep track of pins placed in the scene.
	var detected_pins = get_tree().get_nodes_in_group("Pins");
	for obj in detected_pins:
		if obj is Pin:
			pins.append(obj);
			obj.pin_knocked_over.connect(_on_pin_knocked_over.bind(obj));

func _on_ball_hit_pins(body: Node3D) -> void:
	if not body is Pin: return;
	body = body as Pin;
	
	camera._camera_shake(0.1, 0.1);
	
	if body.is_knocked: return;
	
	Globals.freeze_frame(0.25, 0.1);
	
	if timer.is_stopped(): 
		timer.start();
		timer_started.emit(timer.wait_time);
		await timer.timeout;
		score += len(combo_pins);
		score_updated.emit(score);
		
		combo_pins = [];
	else: 
		return;

func _on_pin_knocked_over(pin: Pin) -> void:
	if pin not in knocked_pins:
		knocked_pins.append(pin);
	if pin not in combo_pins:
		combo_pins.append(pin);
		combo_updated.emit(len(combo_pins));
