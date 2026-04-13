class_name Entity
extends RigidBody2D

@onready var UI = get_tree().get_first_node_in_group("UI")

@onready var death_particles: CPUParticles2D = $DeathParticles

signal died

var is_dead = false

func die(p_num: float = -1) -> void:
	
	# you can only die once
	if not is_dead:
		death_particles.emitting = true
		set_deferred("lock_rotation", false) # makes the thing fall
		is_dead = true
		died.emit()
		
		if p_num != -1:
			var temp_score = Global.score
			temp_score[p_num - 1] -= 1
			Global.set_score(temp_score)
			
