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


#func set_data()
# nope gonna do this later

func _ready() -> void:
	
	Global.score_changed.connect(update_score)
	update_score()

func player_hit(player_num: String, current_hp: float) -> void:
	var hp_bar = top_bar.find_child("HPBar" + player_num)
	
	hp_bar.value = current_hp

func update_score() -> void:
	score_1.text = str(Global.score[0])
	score_2.text = str(Global.score[1])
