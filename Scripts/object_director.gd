extends Node

@export var powerup_scene: PackedScene  # Assign the Power-Up scene in the Inspector
@export var map_bounds: GridMap  # Reference to the GridMap
@export var player: Node3D  # Reference to the player
@export var spawn_radius: float = 10.0  # Max distance from the player
@export var spawn_interval: float = 10.0  # Time between spawns

var min_x: float
var max_x: float
var min_z: float
var max_z: float

func _ready():
	var ui = get_node_or_null("/root/UI")
	if ui and ui.has_signal("game_started"):
		ui.game_started.connect(_on_game_start)
	else:
		print("UI not found, trying dynamic scene detection...")
		wait_for_world()

func _on_game_start():
	print("Game started! Initializing Object Director...")
	initialize_director()

func wait_for_world():
	while not get_node_or_null("/root/World"):
		print("Waiting for game scene to load...")
		await get_tree().process_frame  # Wait a frame
	print("World scene detected!")
	initialize_director()

func initialize_director():
	map_bounds = get_node_or_null("/root/World/GridMap")
	player = get_node_or_null("/root/World/Player")

	if not map_bounds or not player:
		print("ERROR: MapManager or Player not found in World!")
		return

	print("SUCCESS: Game Scene Loaded. MapManager and Player assigned.")
	calculate_map_bounds()
	spawn_powerup()
	get_tree().create_timer(spawn_interval).timeout.connect(spawn_powerup)

func calculate_map_bounds():
	min_x = INF
	max_x = -INF
	min_z = INF
	max_z = -INF

	var used_cells = map_bounds.get_used_cells()
	print("DEBUG: Used cells in GridMap:", used_cells)
	print("DEBUG: GridMap Tile Library:", map_bounds.mesh_library)
	for cell in used_cells:
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_z = min(min_z, cell.z)
		max_z = max(max_z, cell.z)

	print("Calculated map bounds:", min_x, max_x, min_z, max_z)

func spawn_powerup():
	var spawn_location = get_nearby_spawn_location()
	if spawn_location == Vector3.ZERO:
		print("No valid spawn location found.")
		return
	if not powerup_scene: 
		print("No powerup passed in.")
		return
	var powerup = powerup_scene.instantiate()
	powerup.position = spawn_location
	get_tree().current_scene.add_child(powerup)

func get_nearby_spawn_location():
	var max_attempts = 10
	var valid_ground_tiles = [0, 7]  # Only allow spawning on tiles with these IDs

	for i in range(max_attempts):
		var angle = randf() * TAU
		var distance = randf() * spawn_radius
		if not player:
			print("ERROR: Player is NULL!")
			return Vector3.ZERO
		var spawn_x = player.position.x + cos(angle) * distance
		var spawn_z = player.position.z + sin(angle) * distance
		var spawn_pos = Vector3(spawn_x, 10.0, spawn_z)

		if not map_bounds:
			print("ERROR: map_bounds is NULL!")
			return Vector3.ZERO

		var cell = map_bounds.local_to_map(spawn_pos)
		if not cell:
			print("WARNING: local_to_map() returned NULL for", spawn_pos)
			continue

		var cell_item = map_bounds.get_cell_item(Vector3i(cell.x, 0, cell.z))
		print("DEBUG: Cell item for", cell, "is", cell_item)

		if cell_item not in valid_ground_tiles:
			print("WARNING: get_cell_item() returned non-ground tile", cell_item, "for", cell)
			continue

		var local_pos = map_bounds.map_to_local(cell)
		if not local_pos:
			print("WARNING: map_to_local() returned NULL for", cell)
			continue

		spawn_pos.y = local_pos.y + 0.2
		print("SUCCESS: Spawn location found at", spawn_pos)
		return spawn_pos

	print("Couldn't find a valid ground-level spawn after multiple tries.")
	return Vector3.ZERO
