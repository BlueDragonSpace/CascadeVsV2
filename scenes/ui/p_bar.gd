extends HBoxContainer

@export var reverse : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if reverse:
		for i in get_child_count():
			move_child(get_child(-1), 0)
