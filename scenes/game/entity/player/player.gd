class_name Player
extends Entity

@onready var center: Marker2D = $Center
@onready var pin_joint_2d: PinJoint2D = $Center/PinJoint2D
@onready var floorbox: Area2D = $Floorbox
@onready var secondary_timer: Timer = $SecondaryTimer
@onready var secondary_timer_visual: TextureProgressBar = $SecondaryTimerVisual

@export var weapon_scene : PackedScene = null

@export var randomize_character : bool = true
enum CHARACTER {
	BASIC,
	STRONG,
	JUMP,
	FLOAT,
}
@export var chara : CHARACTER = CHARACTER.BASIC

@export var randomize_secondary : bool = true
enum SECONDARY {
	NONE,
	DASH,
	SHIELD,
	AIR_BLOWER,
}
@export var secondary : SECONDARY = SECONDARY.NONE

@export var p_num = 1 # player number, for context of P1 or P2
@export_category("Player Stats")
@export var strength = 10 ## ability to move your weapon
@export var jump_height = 15
@export var max_spd = 8
@export var max_hp = 100
#@export var fall_mult = 1.0 ## Just manipulate gravity_scale
@export_category("Unimplemented")
@export var secondary_cooldown_mult = 1.0
@export var damage_mult = 1.0 
@export var weight_mult = 1.0 # likely just need to change mass for intended results...
@export var lol_you_should_manipulate_hitbox_for_characters = null
# optimally, would have magic or something for secondary


var suffix = 1 # wait isn't this the same thing as p_num?????
var can_jump = false
var current_hp = max_hp
var chara_name = 'Basicface'
var secondary_ready = true # can the secondary be used currently?

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
	if randomize_character:
		# just chooses any random one from the total
		chara = randi_range(0, CHARACTER.size() - 1) as CHARACTER
	
	match(chara):
		CHARACTER.BASIC:
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
			jump_height *= 0.6 # debuff their height or this would be ridiculous
			max_spd *= 1.2
			#max_hp
			gravity_scale *= 0.2 # wow, they don't float, they just ignore gravity!1!11!!!
			chara_name = 'Floatface'
	
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
	if randomize_secondary:
		# can be anything but NONE (the first secondary)
		#secondary = randi_range(1, SECONDARY.size() - 1) as SECONDARY
		secondary = SECONDARY.DASH
	
	UI.call_deferred("set_data", p_num, self)
	
	# editor stuff
	secondary_timer_visual.visible = false
	secondary_timer_visual.value = 0
	


func _input(_event: InputEvent) -> void:
	
	if not is_dead:
		
		#if Input.is_action_just_pressed("jump" + suffix) and can_jump:
		if Input.is_action_just_pressed("jump" + suffix) and floorbox.has_overlapping_bodies() and can_jump:
			apply_impulse(Vector2(0, -jump_height * 100))
			can_jump = false

func _process(_delta: float) -> void:
	
	# updates the secondary_timer
	if not secondary_ready:
		secondary_timer_visual.value = 100 * secondary_timer.time_left / secondary_timer.wait_time

func _physics_process(delta: float) -> void:
	
	if not is_dead:
		
		var x_dir = Input.get_axis("left" + suffix, "right" + suffix)
		var x_speed = x_dir * max_spd * 1000 * delta
		
		## below code makes the player movement not smooth at all, and no air control...
		#if not abs(linear_velocity.x) > max_spd: # if going past max_spd, it's out of control of player, and shouldn't be stopped 
		
		linear_velocity.x = x_speed
		weapon.rotation += Input.get_axis("weapon_left" + suffix, "weapon_right" + suffix) * strength * delta
		
		if Input.is_action_just_pressed("secondary" + suffix) and secondary == SECONDARY.DASH and secondary_ready:
			
			var impulse = Vector2(cos(weapon.rotation), sin(weapon.rotation)) # in direction of weapon
			impulse *= jump_height * 100
			
			apply_central_impulse(impulse)
			
			secondary_timer.start()
			secondary_timer_visual.visible = true
			secondary_ready = false
	
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

## signals
func _on_floor_box_body_entered(_body: Node2D) -> void:
	can_jump = true


func _on_floor_box_body_exited(_body: Node2D) -> void:
	can_jump = false

func _on_secondary_timer_timeout() -> void:
	secondary_ready = true
	secondary_timer_visual.visible = false
	$SecondaryTimerParticles.emitting = true
