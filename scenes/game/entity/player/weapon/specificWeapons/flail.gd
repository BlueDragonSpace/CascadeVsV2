extends Weapon


func add_ready() -> void:
	
	for child in find_children("RigidBody2D"):
		child.collision_layer = collision_layer
		child.collision_mask = collision_mask
