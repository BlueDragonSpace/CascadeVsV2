extends Node2D


func _on_killzone_body_entered(body: Node2D) -> void:
	# effectively kills the body that entered the kill zone
	
	if body.p_num: # does p_num exist?
		body.die(body.p_num) 
	else:
		body.die()
