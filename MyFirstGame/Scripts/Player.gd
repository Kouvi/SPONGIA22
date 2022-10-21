extends KinematicBody2D

export(int) var move_speed = 100
export(int) var jump_impulse = 300
export(int) var enemy_jump_impulse = 300
export(int) var max_jumps = 2
export(int) var flip_cooldown = 5
export(int) var flip_speed = 0

enum STATE { IDLE, RUN, JUMP, FALL, DOUBLE_JUMP, FLIP}

onready var animated_sprite = $AnimatedSprite
onready var animation_tree = $AnimationTree
onready var jump_attack = $JumpAttack

signal changed_state(new_state_string, new_state)

var velocity : Vector2
var can_flip = true
var doubleJumps = 0
var jumpS = 0
var current_state = STATE.IDLE setget set_current_state
var start_timer = false
var timer_length = 18
var current_time = 0
var looking = 1

func _physics_process(delta):
	var input = get_player_input()
	adjust_flip_direction(input)
	velocity = Vector2(
		input.x * move_speed + flip_speed*looking,
		min(velocity.y + GameSettings.gravity, GameSettings.terminal_velocity)
	)
	if(start_timer == true):
		if(current_time <= timer_length):
			current_time += 1
			flip_speed = 200
		else:
			start_timer = false
			flip_speed = 0
			current_time = 0
			can_flip = true
			
	#Character gains velocity and move
	velocity = move_and_slide(velocity, Vector2.UP)
	#Character calls this function to pick a new state
	pick_next_state()
	#Character calls this function to update its animation
	set_anim_parameters()




#Function updates animationtree parameter(flipH) 
func adjust_flip_direction(input: Vector2):
	if(sign(input.x) == 1):
		animated_sprite.flip_h = false
		looking = 1
	elif(sign(input.x) == -1):
		animated_sprite.flip_h = true
		looking = -1




#Function which updates Animation Tree which then updates AnimatedSprite
func set_anim_parameters():
	animation_tree.set("parameters/x_move/blend_position", sign(velocity.x))
	animation_tree.set("parameters/y_sign/blend_amount", sign(velocity.y))




#Fuction which checks characters position and if the character is on floor allows it to jump and also updates States of the character
func pick_next_state():
	if(is_on_floor()&&can_flip == true):
		jumpS = 0
		doubleJumps = 0
		if(Input.is_action_just_pressed("up")):
			self.current_state = STATE.JUMP
		elif(Input.is_action_just_pressed(("flip"))):
			self.current_state = STATE.FLIP
		elif(abs(velocity.x)>0):
			self.current_state = STATE.RUN
		else:
			self.current_state = STATE.IDLE
	elif(can_flip == true):
		if(Input.is_action_just_pressed(("up"))&& jumpS < max_jumps&& doubleJumps ==0):
			self.current_state = STATE.DOUBLE_JUMP
		




#This function registers input from the player and returns it as Vector2
func get_player_input():
	var input : Vector2
	
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return input




func jump():
	velocity.y = -jump_impulse
	jumpS += 1

func _on_JumpAttack_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	var enemy = area.owner
	
	if(enemy is Enemy&&enemy.can_be_hit):
		if(jump_attack.global_position.y < area.global_position.y):
			print("jump HB" + str(jump_attack.global_position))
			print("pos of enemy" + str(area.global_position))
			enemy.get_hit(1)
			velocity.y = 0
			velocity.y -= enemy_jump_impulse


#SETTERS
func set_current_state(new_state):
	match(new_state):
		STATE.JUMP:
			jump()
		STATE.DOUBLE_JUMP:
			jump()
			animation_tree.set("parameters/double_jump/active", true)
			doubleJumps +=1
		STATE.FLIP:
			animation_tree.set("parameters/double_jump/active", true)
			start_timer = true
			can_flip = false
	current_state = new_state
	emit_signal("changed_state", STATE.keys()[new_state], new_state)


