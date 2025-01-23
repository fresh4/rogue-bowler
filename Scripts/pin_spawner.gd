@tool
class_name PinSpawner extends Node3D

@export_enum("PINK", "CYAN", "WHITE") var selected_color: String = "WHITE";
@export var triangle_mesh: CSGMesh3D;
@export var fill_on_start: bool = true;

@onready var pins_scene = preload("res://Prefabs/pin_group.tscn");

var color: Color; ## The color of the spawner, set in the inspector by `selected_color`.
var has_pins: bool = false; ## Whether or not the spawner has pins spawned in it.

func _ready() -> void:
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
	var pins = pins_scene.instantiate();
	add_child(pins);
	for pin in pins.get_children():
		if pin is Pin:
			pin.set_pin_color(color);
	has_pins = true;
