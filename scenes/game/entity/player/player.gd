class_name Player
extends Entity

@onready var center: Marker2D = $Center
@onready var pin_joint_2d: PinJoint2D = $Center/PinJoint2D
@onready var floorbox: Area2D = $Floorbox


@export var p_num = 1 # player number, for context of P1 or P2
@export var strength = 80 ## ability to move your weapon
@export var jump_height = 15
@export var max_spd = 8
@export var max_hp = 100

@export var weapon_scene : PackedScene = null

var suffix = 1
var can_jump = false
var current_hp = max_hp

var weapon : Node = null # defined later

## Godot Built-in Functions

func _ready() -> void:
	suffix = str(p_num)
	
	# define the weapon
	weapon = weapon_scene.instantiate()
	center.add_child(weapon)
	pin_joint_2d.node_b = weapon.get_path()
	
	weapon.hit_entity.connect(deal_hit)
	
	# player num set-up
	if p_num % 2 == 0: # is even?
		weapon.rotation = PI # 180 degreessss
	
	if p_num == 2:
		# so by default, all collisions are set for player 1.
		## manipulate collision layers (yay bitshifting!)
		
		# collides with environment and player 1
		collision_layer = int(pow(2, 4))
		collision_mask  = int(pow(2, 0) + pow(2, 1) + pow(2, 16))
		floorbox.collision_layer = collision_mask
		print(floorbox.collision_layer)
		weapon.collision_layer = int(pow(2, 5))
		weapon.hitbox.collision_mask = int(pow(2,0))
		print(weapon.collision_layer)

func _input(_event: InputEvent) -> void:
	
	if not is_dead:
		
		#if Input.is_action_just_pressed("jump" + suffix) and can_jump:
		if Input.is_action_just_pressed("jump" + suffix) and floorbox.has_overlapping_bodies():
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
