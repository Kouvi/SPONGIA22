extends Enemy

enum STATE{WALK, RUN, HIT}

export(Array, NodePath) var waypoints
export(int) var start_point = 0 
export(int) var walk_speed = 50
export(int) var run_speed = 100
export(int) var waypoint_arrive_distance = 10

var waypoint_position
var waypoint_index setget set_waypoint_index
var is_detected = 0
var velocity = Vector2.ZERO
var current_state = STATE.WALK

onready var animated_sprite = $AnimatedSprite
onready var animation_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	self.waypoint_index = start_point

func _physics_process(delta):
	var direction = self.position.direction_to(waypoint_position)
	var distance_x = Vector2(self.position.x, 0).distance_to(Vector2(waypoint_position.x,0))
	#print(current_state)
	if(distance_x >= waypoint_arrive_distance):
		var direction_x_sign = sign(direction.x)
		
		var move_speed
		
		match(current_state):
			STATE.WALK:
				move_speed = walk_speed
			STATE.RUN:
				move_speed = run_speed
			STATE.HIT:
				move_speed = run_speed*1.75
		velocity = Vector2(
		move_speed * sign(direction.x),
		min(velocity.y + GameSettings.gravity, GameSettings.terminal_velocity)
		)
		
		if(direction_x_sign == 1):
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false
		
		set_anim_parameters(is_detected)
		velocity = move_and_slide(velocity, Vector2.UP)
		
	else:
		#switch waypoints
		var num_waypoints = waypoints.size()
		
		if(waypoint_index < num_waypoints-1):
			self.waypoint_index += 1
		else:
			self.waypoint_index= 0 

func _hit_anim_finished():
	print("hai")
	can_be_hit = true
	current_state = STATE.RUN

func get_hit(damage: float):
	health -= damage
	
	if(health <= 0):
		queue_free()
	
	can_be_hit = false
	current_state = STATE.HIT
	
	var anim_selection = GameSettings.RandomNumGen.randi_range(0, 1)
	
	animation_tree.set("parameters/hit/active", true)
	animation_tree.set("parameters/hit_variation/blend_amount", anim_selection)

func set_anim_parameters(detected):
	animation_tree.set("parameters/player_detect/blend_position", detected)



#SETTERS
func set_waypoint_index(value):
	waypoint_index= value 
	waypoint_position = get_node(waypoints[waypoint_index]).position 


func _on_DetectionZone_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	is_detected = 1
	if(current_state == STATE.WALK):
		current_state = STATE.RUN
	

func _on_DetectionZone_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	is_detected = 0
	if(current_state == STATE.RUN):
		current_state = STATE.WALK
