@tool
extends PowerUp

@export var pin_spawner: PinSpawner; ## Optional. The spawner that this powerup activates.

## On touch by player, pick a spawner in the scene of the same color 
## as this powerup and activate its spawn function. Then, delete this node.
func activate(_body: RigidBody3D) -> void:
	# If we want to activate a specific spawner, do that and return.
	if pin_spawner: 
		queue_free();
		pin_spawner.spawn_pins();
		return; 
	
	# If no specific spawner, pick a random free one and activate it.
	# Get all the spawners in the scene. 
	var pin_spawners = get_tree().get_nodes_in_group("PinSpawners");
	
	# Find all the spawners with no pins.
	var empty_spawners = [];
	for spawner in pin_spawners:
		if not spawner.has_pins:
			empty_spawners.append(spawner);
	
	# Pick a random spawner from the list of empty spawners.
	var chosen_spawner: PinSpawner = empty_spawners.pick_random() as PinSpawner;
	
	# Spawn pins.
	chosen_spawner.spawn_pins();
	
	# Delete the powerup.
	queue_free();
