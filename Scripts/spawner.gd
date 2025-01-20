extends Node3D

@export var powerup_scene: PackedScene  # Drag and drop PowerUp.tscn into this
@export var spawn_interval: float = 30.0  # Time between spawns
@export var spawn_area: AABB = AABB(Vector3(-10, 0, -10), Vector3(20, 0, 20))  # Define spawn area

func _ready():
	# Start the spawn timer
	_spawn_powerup()
	get_tree().create_timer(spawn_interval).timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	_spawn_powerup()

func _spawn_powerup():
	# Instantiate the power-up
	var powerup = powerup_scene.instance()
	var random_pos = Vector3(
		randi_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
		spawn_area.position.y,
		randi_range(spawn_area.position.z, spawn_area.position.z + spawn_area.size.z)
	)
	powerup.translation = random_pos
	add_child(powerup)
