extends Control

@onready var main_container: VBoxContainer = $HBoxContainer/MainContainer
# yes, I know they're arranged weird, just work with me here
@onready var p_bar_1: HBoxContainer = $HBoxContainer/MainContainer/TopBar/PBar1
@onready var score_1: Label = $HBoxContainer/MainContainer/TopBar/PBar1/Score1
@onready var p_bar_2: HBoxContainer = $HBoxContainer/MainContainer/TopBar/PBar2
@onready var score_2: Label = $HBoxContainer/MainContainer/TopBar/PBar2/Score2
@onready var after_1: VBoxContainer = $HBoxContainer/MainContainer/LowerBar/After1
@onready var after_2: VBoxContainer = $HBoxContainer/MainContainer/LowerBar/After2

@onready var after_3: VBoxContainer = $HBoxContainer/MainContainer/LowerBar2/After3
@onready var after_4: VBoxContainer = $HBoxContainer/MainContainer/LowerBar2/After4
@onready var p_bar_3: HBoxContainer = $HBoxContainer/MainContainer/TopBar2/PBar3
@onready var score_3: Label = $HBoxContainer/MainContainer/TopBar2/PBar3/Score3
@onready var p_bar_4: HBoxContainer = $HBoxContainer/MainContainer/TopBar2/PBar4
@onready var score_4: Label = $HBoxContainer/MainContainer/TopBar2/PBar4/Score4

@onready var round_timer: Label = $HBoxContainer/MainContainer/TopBar/PBar1/Timers/RoundTimer
@onready var next_round_timer_label: Label = $HBoxContainer/MainContainer/TopBar/PBar1/Timers/NextRoundTimerLabel
@onready var next_round_timer: Timer = $HBoxContainer/MainContainer/TopBar/PBar1/Timers/NextRoundTimerLabel/NextRoundTimer



@export var max_timer_time : int = 45
@onready var timer_time : float = max_timer_time
@export var disable_timer = false
var timer_running = true

signal out_of_time

func _ready() -> void:
	
	Global.score_changed.connect(update_score)
	update_score()
	
	if disable_timer:
		round_timer.visible = false
		timer_running = false
	
	round_timer.text = str(int(ceil(timer_time)))
	
	# sets all player stats, hp bars, and scores to start as invisible
	# players that appear get their bar added later
	for i in range(1, 5):
		find_child("PBar" + str(i)).visible = false
		find_child("After" + str(i)).visible = false # basically the stats

func _process(delta: float) -> void:
	
	if timer_running:
		timer_time -= delta
		round_timer.text = str(int(ceil(timer_time)))
	else:
		next_round_timer_label.text = str(int(next_round_timer.time_left * 10) / 10.0) # rounds to one decimal
	
	if ceil(timer_time) <= 0:
		timer_running = false
		out_of_time.emit()

## Custom Functions

func set_data(p_num: int, node_data: Node) -> void:
	
	# hp
	var hp_bar = main_container.find_child("HPBar" + str(p_num))
	hp_bar.max_value = node_data.max_hp
	hp_bar.value = hp_bar.max_value
	
	# character name
	var name_name = main_container.find_child("Character" + str(p_num))
	name_name.text = node_data.chara_name
	
	# weapon
	var weapon_text = main_container.find_child("Weapon" + str(p_num))
	weapon_text.text = node_data.weapon.weapon_name
	
	find_child("PBar" + str(p_num)).visible = true
	find_child("After" + str(p_num)).visible = true

func player_hit(player_num: String, current_hp: float) -> void:
	var hp_bar = find_child("HPBar" + player_num)
	
	hp_bar.value = current_hp

func update_score() -> void:
	score_1.text = str(Global.score[0])
	score_2.text = str(Global.score[1])
	score_3.text = str(Global.score[2])
	score_4.text = str(Global.score[3])

func begin_next_round_timer() -> void:
	
	timer_running = false
	next_round_timer.start()

## Signalssss

func _on_next_round_real_timer_timeout() -> void:
	get_tree().reload_current_scene()
