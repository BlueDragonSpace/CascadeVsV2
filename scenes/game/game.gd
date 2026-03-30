extends Node2D

@onready var UI = get_tree().get_first_node_in_group("UI")

@onready var players: Node2D = $Players
@onready var center: Marker2D = $Center
@onready var camera_2d: Camera2D = $Center/Camera2D
@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D
@onready var environment: Node2D = $Center/Environment

@export var player_count = 2
@export var random_stages : Array[PackedScene] = []

const PLAYER = preload("uid://dqts7vo68o24h")

#const SMALL_BATTLEFIELD = preload("uid://bv04btme51quy")
#const FLAT = preload("uid://bslnyut3g8exf")
#const MOVING_PLATFORM = preload("uid://dxcvfndadfugo")
#const WACK_BOXES = preload("uid://dnki7vjywgfxw")

var env_rotate = false
var screenshake = false

func _ready() -> void:
	
	# chooses random environment from the random_stages
	environment.add_child(random_stages[randi_range(0, random_stages.size() - 1)].instantiate())
	
	for i in range(0, player_count):
		var child = PLAYER.instantiate()
		child.p_num = i + 1
		child.position = environment.get_child(0).get_node("Spawnpoints/Marker2D" + str(child.p_num)).position
		
		players.add_child(child)
		
		phantom_camera_2d.follow_targets.push_back(child)
		phantom_camera_2d.follow_targets.push_back(get_node("Test/PathFollow2D/10CubeMiniWrap1_png"))
		print(phantom_camera_2d.follow_targets.size())
	
	UI.out_of_time.connect(time_out_event)

func _physics_process(delta: float) -> void:
	
	if env_rotate:
		center.rotation += 0.2 * delta
	
	if screenshake:
		camera_2d.offset = Vector2(randf_range(-2, 2), randf_range(-2, 2))

func _on_killzone_body_entered(body: Node2D) -> void:
	# effectively kills the body that entered the kill zone
	
	print(phantom_camera_2d.follow_targets.size(), " is the size at time of death")
	
	if body.p_num: # does p_num exist?
		body.die(body.p_num)
	else:
		body.die()

func time_out_event() -> void:
	
	# now Ideally I would randomize this for different events like fire rain, but for now this will do
	env_rotate = true
	screenshake = true
