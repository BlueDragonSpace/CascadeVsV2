extends Node

## Global script, meaning this stuff can be accessed in any place

# player scores
var score = [0,0]

signal score_changed

func empty_function() -> void:
	print('empty_function')

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func set_score(new_score: Array) -> void:
	# guhhhhh set method doesn't wanna work for some reason
	
	score = new_score
	score_changed.emit()
	
