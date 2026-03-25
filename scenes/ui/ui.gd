extends Control

@onready var top_bar: HBoxContainer = $HBoxContainer/VBoxContainer/TopBar

@onready var character: Label = $HBoxContainer/VBoxContainer/HBoxContainer/After/Character
@onready var weapon: Label = $HBoxContainer/VBoxContainer/HBoxContainer/After/Weapon
@onready var secondary: Label = $HBoxContainer/VBoxContainer/HBoxContainer/After/Secondary
@onready var character_2: Label = $HBoxContainer/VBoxContainer/HBoxContainer/After2/Character2
@onready var weapon_2: Label = $HBoxContainer/VBoxContainer/HBoxContainer/After2/Weapon2
@onready var secondary_2: Label = $HBoxContainer/VBoxContainer/HBoxContainer/After2/Secondary2
@onready var score_1: Label = $HBoxContainer/VBoxContainer/BottomBar/Score1
@onready var score_2: Label = $HBoxContainer/VBoxContainer/BottomBar/Score2

@onready var timer: Label = $HBoxContainer/VBoxContainer/TopBar/Timer

@export var max_timer_time : int = 45
@onready var timer_time : float = max_timer_time
@export var disable_timer = false
var timer_running = true

signal out_of_time

func set_data(p_num: int, node_data: Node) -> void:
	
	var hp_bar = find_child("HPBar" + str(p_num))
	hp_bar.max_value = node_data.max_hp
	hp_bar.value = hp_bar.max_value
	

func _ready() -> void:
	
	Global.score_changed.connect(update_score)
	update_score()
	
	if disable_timer:
		timer.visible = false
		timer_running = false
	
	timer.text = str(int(ceil(timer_time)))

func _process(delta: float) -> void:
	
	if timer_running:
		timer_time -= delta
		timer.text = str(int(ceil(timer_time)))
	
	if ceil(timer_time) <= 0:
		timer_running = false
		out_of_time.emit()

func player_hit(player_num: String, current_hp: float) -> void:
	var hp_bar = top_bar.find_child("HPBar" + player_num)
	
	hp_bar.value = current_hp

func update_score() -> void:
	score_1.text = str(Global.score[0])
	score_2.text = str(Global.score[1])
