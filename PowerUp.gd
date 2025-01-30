extends Area3D

signal object_destroyed  # Signal to notify the director

@export var lifespan: float = 10.0  # How long before it despawns

func _ready():
	# Start the timer for self-destruction
	get_tree().create_timer(lifespan).timeout.connect(self_destruct)

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("object_destroyed", self)  # Notify the director
		queue_free()  # Destroy itself

func self_destruct():
	emit_signal("object_destroyed", self)  # Notify before destruction
	queue_free()
