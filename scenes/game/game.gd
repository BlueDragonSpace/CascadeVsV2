extends Node2D


func _on_killzone_body_entered(body: Node2D) -> void:
	# effectively kills the body that entered the kill zone
	body.die()
