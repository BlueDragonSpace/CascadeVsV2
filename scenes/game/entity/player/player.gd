class_name Player
extends Entity

@onready var center: Marker2D = $Center
@onready var pin_joint_2d: PinJoint2D = $Center/PinJoint2D
@onready var floorbox: Area2D = $Floorbox
@onready var camera_link: RemoteTransform2D = $CameraLink

@export var weapon_scene : PackedScene = null

@export var randomize_character : bool = true
enum CHARACTER {
	BASIC,
	STRONG,
	JUMP,
	FLOAT,
}
@export var chara : CHARACTER = CHARACTER.BASIC

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


var suffix = 1
var can_jump = false
var current_hp = max_hp
var chara_name = 'Basicface'

var weapon : Node = null # defined later

const FLAIL = preload("uid://d2afk51jtpk85")
const HOTDOG = preload("uid://d021frcs6rcos")
const SPEAR = preload("uid://b2m3cvbsfphco")

## Godot Built-in Functions

func _ready() -> void:
	suffix = str(p_num)
	
	## define the weapon
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
	
	if randomize_character:
		# just chooses a random one from the total
		@warning_ignore("int_as_enum_without_cast")
		chara = randi_range(1, CHARACTER.size() as int)
	
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
	
	center.add_child(weapon)
	pin_joint_2d.node_b = weapon.get_path()
	weapon.hit_entity.connect(deal_hit)
	
	# player num set-up
	if p_num % 2 == 0: # is even?
		weapon.rotation = PI # 180 degreessss
	
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
	
	UI.call_deferred("set_data", p_num, self)

func _input(_event: InputEvent) -> void:
	
	if not is_dead:
		
		#if Input.is_action_just_pressed("jump" + suffix) and can_jump:
		if Input.is_action_just_pressed("jump" + suffix) and floorbox.has_overlapping_bodies() and can_jump:
			apply_impulse(Vector2(0, -jump_height * 100))
			can_jump = false

func _physics_process(delta: float) -> void:
	
	if not is_dead:
		
		var x_dir = Input.get_axis("left" + suffix, "right" + suffix)
		var x_speed = x_dir * max_spd * 1000 * delta
		linear_velocity.x = x_speed
		weapon.rotation += Input.get_axis("weapon_left" + suffix, "weapon_right" + suffix) * strength * delta

## custom functions
func deal_hit(entity: Entity) -> void:
	# your stat: damage dealt! goes up
	
	entity.take_hit(weapon.damage)

func take_hit(damage: float) -> void:
	# increase your stat: damage taken! going up and so on
	
	current_hp -= damage
	
	UI.player_hit(suffix, current_hp)
	
	if current_hp <= 0:
		die(p_num)

## signals
func _on_floor_box_body_entered(_body: Node2D) -> void:
	can_jump = true


func _on_floor_box_body_exited(_body: Node2D) -> void:
	can_jump = false
