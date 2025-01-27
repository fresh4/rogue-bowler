@tool
class_name PinSpawner extends Node3D

@export_enum("PINK", "CYAN", "WHITE") var selected_color: String = "WHITE";
@export var triangle_mesh: CSGMesh3D;
@export var fill_on_start: bool = true;

@onready var pins_scene = preload("res://Prefabs/pin_group.tscn");

var color: Color; ## The color of the spawner, set in the inspector by `selected_color`.
var has_pins: bool = false; ## Whether or not the spawner has pins spawned in it.
var level_manager: LevelManager;

func _ready() -> void:
	level_manager = get_tree().get_first_node_in_group("LevelManager") as LevelManager;
	set_spawner_color();
	# Only run the following in game.
	if Engine.is_editor_hint(): return;
	if fill_on_start: spawn_pins();

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		set_spawner_color();

func set_spawner_color() -> void:
	color = Globals.get(selected_color);
	triangle_mesh.material.albedo_color = color;
	triangle_mesh.material.emission = color;

func spawn_pins() -> void:
	for c in get_children(): c.queue_free(); # Delete any pins if they exist.
	var pins = pins_scene.instantiate();
	add_child(pins);
	for pin in pins.get_children():
		if pin is Pin:
			pin.set_pin_color(color);
			level_manager.pins.append(pin);
			pin.pin_knocked_over.connect(level_manager._on_pin_knocked_over.bind(pin));
	has_pins = true;
