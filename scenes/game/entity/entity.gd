@abstract
class_name Entity
extends RigidBody2D

@onready var death_particles: CPUParticles2D = $DeathParticles

func die() -> void:
	death_particles.emitting = true
