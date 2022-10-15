extends KinematicBody2D

export(float) var move_speed = 100
export(float) var jump_impulse = 200

enum STATE { IDLE, RUN, JUMP, FALL}

onready var animated_sprite = $AnimatedSprite
onready var animation_tree = $AnimationTree

var velocity : Vector2

var jumpS = 0
var current_state = STATE.IDLE setget set_current_state

func _physics_process(delta):
	var input = get_player_input()
	adjust_flip_direction(input)
	velocity = Vector2(
		input.x * move_speed,
		min(velocity.y + GameSettings.gravity, GameSettings.terminal_velocity)
	)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	pick_next_state()
	
	set_anim_parameters()

func adjust_flip_direction(input: Vector2):
	if(sign(input.x) == 1):
		animated_sprite.flip_h = false
	elif(sign(input.x) == -1):
		animated_sprite.flip_h = true
	
func set_anim_parameters():
	animation_tree.set("parameters/x_move/blend_position", sign(velocity.x))

func pick_next_state():
	if(is_on_floor()):
		jumpS = 0
		if(Input.is_action_just_pressed("up")):
			self.current_state = STATE.JUMP
		elif(abs(velocity.x)>0):
			self.current_state = STATE.RUN
		else:
			self.current_state = STATE.IDLE
	else:
		#TODO Double Jump
		pass


func get_player_input():
	var input : Vector2
	
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return input
	
func jump():
	velocity.y = -jump_impulse
	jumpS += 1

#SETTERS
func set_current_state(new_state):
	match(new_state):
		STATE.JUMP:
			jump()
	
	current_state = new_state
#GETTERS
