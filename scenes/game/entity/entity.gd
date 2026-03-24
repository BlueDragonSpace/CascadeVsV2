class_name Entity
extends RigidBody2D

@onready var UI = get_tree().get_first_node_in_group("UI")

@onready var death_particles: CPUParticles2D = $DeathParticles

func die() -> void:
	death_particles.emitting = true
