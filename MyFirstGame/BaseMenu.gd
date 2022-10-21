extends Control

onready var day_counter = $VBoxContainer2/DayCounter

var current_health 
var current_food
var current_resources
var current_day


func _ready():
	#print(Inventory.get_stats("d"))
	#current_day = int(Inventory.get_stats("d"))
	#day_counter.text = "Day:  " + str(current_day)
	pass
func _on_Button_pressed():
	get_tree().change_scene("res://Node2D.tscn")


func _on_Button2_pressed():
	#current_day += 1
	#Inventory.day = current_day
	#day_counter.text = "Day:  " + str(current_day)
	pass

func _on_Button3_pressed():
	pass
