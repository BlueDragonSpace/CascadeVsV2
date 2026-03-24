class_name Player
extends Entity

@onready var center: Marker2D = $Center
@onready var pin_joint_2d: PinJoint2D = $Center/PinJoint2D


@export var p_num = 1 # player number, for context of P1 or P2
@export var strength = 80 ## ability to move your weapon
@export var jump_height = 15
@export var max_spd = 8

@export var weapon_scene : PackedScene = null

var suffix = 1
var can_jump = false

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

func _input(_event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("jump" + suffix) and can_jump:
		apply_impulse(Vector2(0, -jump_height * 100))
		can_jump = false
	

func _physics_process(delta: float) -> void:
	#linear_velocity.x = Input.get_axis("left" + suffix, "right" + suffix) * max_spd * delta
	
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
	
	UI.player_hit(suffix, damage)

## signals
func _on_floor_box_body_entered(_body: Node2D) -> void:
	can_jump = true


func _on_floor_box_body_exited(_body: Node2D) -> void:
	can_jump = false
