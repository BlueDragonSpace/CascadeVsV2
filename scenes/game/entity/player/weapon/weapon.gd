class_name Weapon
extends RigidBody2D

@export var damage = 20

signal hit_entity(entity)

func _on_hitbox_body_entered(body: Node2D) -> void:
	hit_entity.emit(body)
