extends Node3D

# Duration before the power-up disappears
@export var duration = 60.0

# Signal to notify when the power-up is collected
signal collected

func _ready():
	# Start a timer to delete the power-up after `duration` seconds
	await get_tree().create_timer(duration).timeout
	queue_free()

func _on_Area3D_body_entered(body):
	if body.name == "Player":  # Replace "Player" with your actual player node's name
		emit_signal("collected")
		queue_free()  # Remove the power-up after collection
