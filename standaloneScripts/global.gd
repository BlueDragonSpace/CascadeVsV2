extends Node

func empty_function() -> void:
	print('empty_function')

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
