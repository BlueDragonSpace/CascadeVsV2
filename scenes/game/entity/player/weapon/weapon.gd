class_name Weapon
extends RigidBody2D

@export var weapon_name = "Im weapon"
@export var damage = 20
@onready var hitbox: Area2D = find_child("Hitbox")

signal hit_entity(entity)

func _on_hitbox_body_entered(body: Node2D) -> void:
	hit_entity.emit(body)

func update_hitbox_layers() -> void:
	# basically an extended function for further classes
	# I would use Godot's @virtual and @abstract, but they come with so much hassle
	pass
