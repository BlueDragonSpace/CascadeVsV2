class_name Weapon

extends AnimatableBody2D

signal hit_entity(entity)

func _on_hitbox_body_entered(body: Node2D) -> void:
	hit_entity.emit(body)
