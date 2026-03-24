extends Entity

@export var p_num = 1 # player number, for context of P1 or P2
@export var jump_height = 400
var suffix = 1

func _ready() -> void:
	suffix = str(p_num)


func _input(event: InputEvent) -> void:
	
	match(event):
		Input.is_action()
	if Input.is_action_just_pressed("jump" + suffix):
		apply_impulse(Vector2(0, -jump_height))
	
	
