extends Node2D

@onready var UI = get_tree().get_first_node_in_group("UI")

@onready var players: Node2D = $Players
@onready var center: Marker2D = $Center
@onready var camera_2d: Camera2D = $Center/BattleCam
@onready var environment: Node2D = $Center/Environment
@onready var firewalls: Area2D = $Firewalls


@export var player_count = 2
@export var random_stages : Array[PackedScene] = []
@export var use_round_modifiers : bool = true
@export var dynamic_camera : bool = true

@export_category("Force Random Events")
@export var use_force_events : bool = false 
@export var force_round_modifier : ROUND_MODIFIERS # does not override use_round_modifiers
@export var force_timeout_modifier : TIMEOUT_MODIFIERS

enum ROUND_MODIFIERS {
	BASIC,
	LOW_GRAVITY,
	#NO_GRAVITY # (really bad, not funnnnn)
	ONE_SHOT,
	SLOW_SPEED,
	FAST_SPEED,
	# KNOCKBACK, # ideally like Smash Bros, ya know?
	# SOCCER, # yeah this would be wild
	
}

enum TIMEOUT_MODIFIERS {
	EARTHQUAKE,
	FIREWALLS,
	#FLOOR_IS_LAVA,
	#THE_RAIN,
	#FALLING_SKY
}

# enum for camera focuses? like on Players, Timeout, maybe some goal?
# or could be best to simply use another camera

const PLAYER = preload("uid://dqts7vo68o24h")

var do_timeout = false # do the timeout event (cancel if all other players die)
var timeout_event = randi_range(0, TIMEOUT_MODIFIERS.size() - 1) as TIMEOUT_MODIFIERS
var env_rotate = false
var screenshake = false
var timeout_camera = false # maxes out camera to see timeout_event

var player_death_count = 0
var current_modifier = randi_range(0, ROUND_MODIFIERS.size() - 1) as ROUND_MODIFIERS

func _ready() -> void:
	
	# chooses random environment from the random_stages
	environment.add_child(random_stages[randi_range(0, random_stages.size() - 1)].instantiate())
	
	# initializes players
	for i in range(0, player_count):
		var child = PLAYER.instantiate()
		child.p_num = i + 1
		var new_position : Vector2 = environment.get_child(0).get_node("Spawnpoints/Marker2D" + str(child.p_num)).global_position
		child.position = new_position
		players.add_child(child)
		
		child.connect("died", player_death.bind(child))
	
	# resetting certain round modifiers
	Engine.time_scale = 1.0
	
	if use_force_events:
			current_modifier = force_round_modifier as ROUND_MODIFIERS
			timeout_event = force_timeout_modifier as TIMEOUT_MODIFIERS
	
	# randomly chooses a modifier and applies it (if round modifiers are enabled)
	if use_round_modifiers:
		
		var t = '' # shorthand for accessing UI text thing later
		
		match(current_modifier):
			ROUND_MODIFIERS.BASIC:
				pass # nothing lol
			ROUND_MODIFIERS.LOW_GRAVITY:
				#this is probably a temporary solution anyway
				
				## sets zero gravity (not reccomended)
				#$NoGravity/NoGravityCollider.disabled = false
				
				$NoGravity.gravity = $NoGravity.gravity / 2.0
				t = 'Low Gravity'
			ROUND_MODIFIERS.ONE_SHOT:
				for player in players.get_children():
					player.current_hp = 1 # wow they have one health like in One Shot
				# funny enough this doesn't change the hp visual so it works perfectly
				t = 'One Shot'
			ROUND_MODIFIERS.SLOW_SPEED:
				Engine.time_scale = 0.5
				t = 'Slow Motion'
			ROUND_MODIFIERS.FAST_SPEED:
				Engine.time_scale = 2
				t = '2x Speed!'
			_:
				t = 'this should be an error lol \nunknown  round modifier'
		
		UI.call_deferred("set_round_modifier",t)
	else:
		UI.call_deferred("set_round_modifier", "OFF") # code word that invisibles it
	
	UI.out_of_time.connect(time_out_event)

func _process(delta: float) -> void:
	
	## Camera stuff lol
	if dynamic_camera:
		# sums up player positions and makes the camera go toward their center
		var positions : Array[Vector2] = []
		for player in players.get_children():
			positions.push_back(player.global_position)
		var center_of_players = calc_mean_vec2(positions)
		
		camera_2d.global_position = center_of_players
		
		## zooms based on the player distance from camera center
		
		if not timeout_camera:
			# find the distance from the camera for all players
			var distances = []
			for pos in positions:
				distances.push_back(camera_2d.global_position.distance_to(pos))
			# find whatever the farthest distance is
			var max_dist = distances.max()
			# zoom to fit it (or not)
				# 128 is a healthy distance and results the zoom defaulting to 3.0 (at least on the x-axis, might need more testing for y-axis stuff)
				# at a farther distance (above 128), the zoom should be less, and vice versa
			var perfect_cam_zoom : float = clamp(128/float(max_dist) * 3, 2, 5)
			# now, to smooth it... the camera can only change it's zoom by a certain max amount per frame (very small)
			# the camera constantly is trying to get to this perfect value, slowly
			var cam_zoom = lerp(camera_2d.zoom.x, perfect_cam_zoom, 0.05)
			
			camera_2d.zoom = Vector2(cam_zoom, cam_zoom)
		
	# camera timeout effects
	if do_timeout:
		
		if env_rotate:
			center.rotation += 0.2 * delta
		
		if screenshake:
			camera_2d.offset = Vector2(randf_range(-2, 2), randf_range(-2, 2))
		
		if timeout_event == TIMEOUT_MODIFIERS.FIREWALLS:
			var redo_cam_zoom = lerp(camera_2d.zoom.x, (128 * 4)/float(firewalls.get_child(1).position.x), 0.03) # maxes out, slowly, initially
			redo_cam_zoom = clamp(redo_cam_zoom, 1.0, 5.0)
			camera_2d.zoom = Vector2(redo_cam_zoom, redo_cam_zoom)
			#also resets camera offsets
			camera_2d.global_position = Vector2(0, 0)
			
			# finally, something that doesn't involve the camera
			var firewall_speed : float = 20.0
			firewalls.get_child(0).position.x = min(firewall_speed * delta + firewalls.get_child(0).position.x, 0)
			firewalls.get_child(1).position.x = max(-firewall_speed * delta + firewalls.get_child(1).position.x, 0)

func _on_killzone_body_entered(body: Node2D) -> void:
	# effectively kills the body that entered the kill zone
	# also the same script for firewalls
	
	if body.p_num: # does p_num exist?
		body.die(body.p_num)
	else:
		body.die()

## custom functions

func player_death(body) -> void:
	
	body.modulate = Color.BLACK
	player_death_count += 1
	
	UI.player_death(body.p_num)
	
	if player_death_count >= player_count - 1:
		UI.begin_next_round_timer()

func time_out_event() -> void:
	
	do_timeout = true
	
	# now Ideally I would randomize this for different events like fire rain, but for now this will do
	match timeout_event:
		TIMEOUT_MODIFIERS.EARTHQUAKE:
			env_rotate = true
			screenshake = true
		TIMEOUT_MODIFIERS.FIREWALLS:
			timeout_camera = true
			firewalls.monitoring = true

func calc_mean_vec2(nums: Array[Vector2]) -> Vector2:
	
	var mean := Vector2(0, 0)
	for num in nums:
		mean += num
	
	mean.y /= nums.size()
	mean.x /= nums.size()
	
	return mean
