extends Node2D

@onready var UI = get_tree().get_first_node_in_group("UI")

@onready var players: Node2D = $Players
@onready var center: Marker2D = $Center
@onready var camera_2d: Camera2D = $Center/Camera2D
@onready var environment: Node2D = $Center/Environment

@export var player_count = 2

const PLAYER = preload("uid://dqts7vo68o24h")

const SMALL_BATTLEFIELD = preload("uid://bv04btme51quy")
const FLAT = preload("uid://bslnyut3g8exf")
const MOVING_PLATFORM = preload("uid://dxcvfndadfugo")
const WACK_BOXES = preload("uid://dnki7vjywgfxw")

var env_rotate = false
var screenshake = false

func _ready() -> void:
	
	# chooses random environment
	match(randi_range(0, 3)):
		0:
			environment.add_child(SMALL_BATTLEFIELD.instantiate())
		1:
			environment.add_child(FLAT.instantiate())
		2:
			environment.add_child(MOVING_PLATFORM.instantiate())
		3:
			environment.add_child(WACK_BOXES.instantiate())
	
	for i in range(0, player_count):
		var child = PLAYER.instantiate()
		child.p_num = i + 1
		child.position = environment.get_child(0).get_node("Spawnpoints/Marker2D" + str(child.p_num)).position
		
		players.add_child(child)
	
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
