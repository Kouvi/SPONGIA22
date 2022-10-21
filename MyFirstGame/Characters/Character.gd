extends KinematicBody2D

class_name Character

export(float) var health = 3

func _get_hit(damage: float):
	push_error("get hit was not implemented in here")
