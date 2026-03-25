extends Node2D

@onready var UI = get_tree().get_first_node_in_group("UI")

@onready var center: Marker2D = $Center
@onready var camera_2d: Camera2D = $Center/Camera2D
@onready var environment: Node2D = $Center/Environment

const SMALL_BATTLEFIELD = preload("uid://bv04btme51quy")
const FLAT = preload("uid://bslnyut3g8exf")

var env_rotate = false
var screenshake = false

func _ready() -> void:
	
	
	
	UI.out_of_time.connect(time_out_event)

func _physics_process(delta: float) -> void:
	
	if env_rotate:
		center.rotation += 0.2 * delta
	
	if screenshake:
		camera_2d.offset = Vector2(randf_range(-2, 2), randf_range(-2, 2))

func _on_killzone_body_entered(body: Node2D) -> void:
	# effectively kills the body that entered the kill zone
	
	if body.p_num: # does p_num exist?
		body.die(body.p_num)
	else:
		body.die()

func time_out_event() -> void:
	
	# now Ideally I would randomize this for different events like fire rain, but for now this will do
	env_rotate = true
	screenshake = true
