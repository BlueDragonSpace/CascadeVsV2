extends Weapon

func update_hitbox_layers() -> void:
	
	for child in find_children("RigidBody2D"):
		child.collision_layer = collision_layer
		child.collision_mask = collision_mask
