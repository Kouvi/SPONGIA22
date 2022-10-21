extends Node


export(float) var gravity = 20
export(float) var terminal_velocity = 150
export(bool) var should_randomize = true



onready var RandomNumGen = RandomNumberGenerator.new()

func _ready():
	if(should_randomize):
		RandomNumGen.randomize()
	
