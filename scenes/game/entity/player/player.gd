class_name Player
extends Entity

@onready var center: Marker2D = $Center
@onready var pin_joint_2d: PinJoint2D = $Center/PinJoint2D
@onready var floorbox: Area2D = $Floorbox
@onready var secondary_timer: Timer = $SecondaryTimer
@onready var secondary_timer_visual: TextureProgressBar = $SecondaryTimerVisual

# should probably turn secondaries into their own class, like the weapons, for now they all live in the player
@onready var air_blower_particles: CPUParticles2D = $AirBlowerParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var weapon_scene : PackedScene = null

enum CHARACTER {
	BASIC,
	STRONG,
	JUMP,
	FLOAT,
}
@export var chara : CHARACTER = CHARACTER.BASIC

enum SECONDARY {
	NONE,
	DASH,
	#SHIELD, 
	AIR_BLOWER, # basically dash but no cooldown and less powerful
}
@export var secondary : SECONDARY = SECONDARY.NONE

@export var p_num = 1 # player number, for context of P1 or P2
@export_category("Player Stats")
@export var strength = 10 ## ability to move your weapon
@export var jump_height : float = 15
@export var acceleration = 5 # how fast can you get to max_spd
@export var deacceleration = 32 * 10 # how quickly you stop moving once you stop pressing anything
@export var max_spd = 8 * 10
@export var max_hp = 100
#@export var fall_mult = 1.0 ## Just manipulate gravity_scale
@export_category("Unimplemented")
@export var secondary_cooldown_mult = 1.0
@export var damage_mult = 1.0 
@export var weight_mult = 1.0 # likely just need to change mass for intended results...
@export var enable_crouch = false # crouching exists, but feels a little half implemented...
# optimally, would have magic or something for secondary


var suffix = 1 # wait isn't this the same thing as p_num?????

var current_hp = max_hp
var chara_name = 'Basicface'
var secondary_ready = true # can the secondary be used currently?
var secondary_name = 'None'

# should be turned into a state machine, rather than abstract booleans
var can_jump = false
var crouching : bool = false
var in_air : bool = false # mostly just the opposite of can_jump
var can_fast_fall : bool = false # in_air, but cannot fast fall twice

var weapon : Node = null # defined later

const FLAIL = preload("uid://d2afk51jtpk85")
const HOTDOG = preload("uid://d021frcs6rcos")
const SPEAR = preload("uid://b2m3cvbsfphco")

## Godot Built-in Functions

func _ready() -> void:
	
	## define the WEAPON
	if weapon_scene: # if weapon_scene is defined
		weapon = weapon_scene.instantiate()
	else: # get random weapon, if none is defined
		match(randi_range(0, 2)):
			0:
				weapon = SPEAR.instantiate()
			1:
				weapon = HOTDOG.instantiate()
			2:
				weapon = FLAIL.instantiate()
	
	center.add_child(weapon)
	pin_joint_2d.node_b = weapon.get_path()
	weapon.hit_entity.connect(deal_hit)
	
	if p_num % 2 == 0: # is even (i.e. on the right side of battlefield)?
		weapon.rotation = PI # 180 degreessss
	
	
	## CHARACTER STATS
	set_character_stats(randi_range(0, CHARACTER.size() - 1))
	
	## player num set-up
	suffix = str(p_num)
	
	if p_num != 1:
		# so by default, all collisions are set for player 1.
		## manipulate collision layers (yay bitshifting!)
		
		# collides with environment and player 1
		collision_layer = int(pow(2, 4 * (p_num - 1)))
		# initial collision mask (colliding with everything including itself
		var temp_collision_mask = 0
		for i in range(17):
			temp_collision_mask += pow(2, i)
		
		# subtracts all flags part of this player
		for i in range(4):
			temp_collision_mask -= pow(2, (p_num - 1) * 4 + i)
		
		collision_mask = temp_collision_mask
		
		floorbox.collision_mask = collision_mask
		weapon.collision_layer = int(pow(2, (p_num - 1) * 4 + 1))
		
		var temp_weapon_collision_mask = 0
		# weapon hits all but own self
		for i in range(1, 5):
			if i == p_num:
				pass
			else:
				temp_weapon_collision_mask += int(pow(2, (i - 1) * 4))
		
		# test the masksssssss
		weapon.hitbox.collision_mask = temp_weapon_collision_mask
		
		weapon.update_hitbox_layers()
	
	
	## SECONDARY
	set_secondary(randi_range(1, SECONDARY.size() - 1))
	
	UI.call_deferred("set_data", p_num, self)
	
	# editor stuff
	secondary_timer_visual.visible = false
	secondary_timer_visual.value = 0
	

func _input(_event: InputEvent) -> void:
	
	# used for one time events, generally
	
	if not is_dead:
		
		# jump
		if Input.is_action_just_pressed("jump" + suffix) and floorbox.has_overlapping_bodies() and can_jump:
			apply_central_impulse(Vector2(0, -jump_height * 100))
			can_jump = false # sometimes results in not being able to jump?
			# but without, can superjump by hitting jump fast enough in a single frame
		
		# crouch
		if Input.is_action_just_pressed("down" + suffix) and enable_crouch:
			animation_player.play("crouch")
			crouching = true

func _process(_delta: float) -> void:
	
	# updates the secondary_timer
	if not secondary_ready:
		secondary_timer_visual.value = 100 * secondary_timer.time_left / secondary_timer.wait_time

func _physics_process(delta: float) -> void:
	
	if not is_dead:
		
		# x movement
		
		var x_dir = Input.get_axis("left" + suffix, "right" + suffix)
		var x_speed = x_dir * acceleration * 1000 * delta
		
		if (Input.is_action_pressed("left" + suffix) and linear_velocity.x > -max_spd) \
		or (Input.is_action_pressed("right" + suffix) and linear_velocity.x < max_spd):
			linear_velocity.x += x_speed
		
		elif (not Input.is_action_pressed("left" + suffix) and linear_velocity.x < 0) or  \
		(not Input.is_action_pressed("right" + suffix) and linear_velocity.x > 0):
			linear_velocity.x = move_toward(linear_velocity.x, 0, deacceleration * 100,) # deacceleration
			# at a certain point it rounds to basically 0 but keeps trying to calculate it over and over
			# note that this still doesn't fix it :\
			if linear_velocity.x > -0.1 and linear_velocity.x < 0.1:
				linear_velocity.x = 0

		# this is a simple and pretty good solution, but fails to interpret air dash
		#linear_velocity.x = x_speed
		
		# fast-fall
		if in_air and Input.is_action_just_pressed("down" + suffix) and can_fast_fall:
			can_fast_fall = false
			apply_central_impulse(Vector2(0, jump_height * 100))
		
		# release crouching
		if crouching and not Input.is_action_pressed("down" + suffix) and not in_air and enable_crouch:
			crouching = false
			animation_player.play_backwards("crouch")
		
		# weapon
		weapon.rotation += Input.get_axis("weapon_left" + suffix, "weapon_right" + suffix) * strength * delta
		
		# secondaries
		match(secondary):
			SECONDARY.DASH:
				if Input.is_action_just_pressed("secondary" + suffix) and secondary_ready:
					
					var impulse = Vector2(cos(weapon.rotation), sin(weapon.rotation)) # in direction of weapon
					impulse *= jump_height * 100
					
					apply_central_impulse(impulse)
					
					secondary_timer.start()
					secondary_timer_visual.visible = true
					secondary_ready = false
				
			SECONDARY.AIR_BLOWER: 
				if Input.is_action_pressed("secondary" + suffix):
					var impulse = Vector2(cos(weapon.rotation), sin(weapon.rotation)) # in direction of weapon
					impulse *= jump_height * -1 # note how this is less powerful than DASH (and negative
					
					linear_velocity += impulse
					air_blower_particles.emitting = true
					air_blower_particles.direction = -impulse.normalized()
				else:
					air_blower_particles.emitting = false
	
	if $LeftWallbox.has_overlapping_bodies(): #aka is hitting a left wall
		linear_velocity.x = clamp(linear_velocity.x, 0, INF)
	if $RightWallbox.has_overlapping_bodies(): #aka is hitting a right wall
		linear_velocity.x = clamp(linear_velocity.x, -INF, 0)

## custom functions
func deal_hit(entity: Entity) -> void:
	# your stat: damage dealt! goes up
	
	entity.take_hit(weapon.damage)

func take_hit(damage: float) -> void:
	# increase your stat: damage taken! going up and so on
	
	current_hp -= damage
	
	UI.player_hit(p_num, current_hp)
	
	if current_hp <= 0:
		die(p_num)

func set_character_stats(input: int) -> void:
	
	chara = input as CHARACTER
	
	match(chara):
		CHARACTER.BASIC:
			# could lead to an error where it doesn't reset stats for a changing character tho :/
			pass # lol basic stats
			
		CHARACTER.STRONG:
			strength *= 1.5
			jump_height *= 0.7
			max_spd *= 0.7
			max_hp *= 1.2
			chara_name = 'Strongface' 
			
		CHARACTER.JUMP:
			strength *= 0.6
			jump_height *= 1.6
			max_spd *= 1.4
			max_hp *= .8
			chara_name = 'Jumpface'
			
		CHARACTER.FLOAT:
			strength *= 0.8
			jump_height *= 0.6 # debuff their jump height or this would be ridiculous
			max_spd *= 1.2
			#max_hp
			gravity_scale *= 0.2 # wow, they don't float, they just ignore gravity!1!11!!!
			chara_name = 'Floatface'
	

func set_secondary(input: int) -> void:
	
	secondary = input as SECONDARY
	
	match(secondary):
		SECONDARY.NONE:
			secondary_name = 'None'
		SECONDARY.DASH:
			secondary_name = 'Dash'
		SECONDARY.AIR_BLOWER:
			secondary_name = 'Air Blower'
		_:
			secondary_name = 'unknown secondary index error lol'

## signals
func _on_floor_box_body_entered(_body: Node2D) -> void:
	can_jump = true
	
	in_air = false
	can_fast_fall = false

func _on_floor_box_body_exited(_body: Node2D) -> void:
	can_jump = false
	
	in_air = true
	can_fast_fall = true

func _on_secondary_timer_timeout() -> void:
	secondary_ready = true
	secondary_timer_visual.visible = false
	$SecondaryTimerParticles.emitting = true
