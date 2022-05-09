extends KinematicBody2D

onready var anim = $AnimationPlayer
var velocity = Vector2() #Final value that is passed to move and slide.
var input_velocity = Vector2() #Desired velocity according to inputs
var jump_avail = true #Track if player has a jump available
var gravity_delta = 0
var gravity_peak_delta = 0
export (float) var speed_x = 300 #Universal speed multiplier for the x axis
export (float) var speed_y = 200 #Universal speed multiplier for the y axis
export (float) var gravity = -50 #Gravity multiplier
export (int) var walk_drag = 3 #Startup Delay of horizontal movement
export (int) var air_drag = 10
export (float) var gravity_peak = -50
export (float) var jump_weight = 0.05

func _ready():
	pass

func get_input():
	#Grabs desired input direction, does not handle physics for said inputs
	#Returns the velocity changes to the _physics_process()
	
	input_velocity = Vector2()
	
	#Check if players jump is replenished
	if is_on_floor() and !jump_avail:
		jump_avail = true
	
	#Handle Inputs
	if Input.is_action_pressed("Left"):
		input_velocity.x -= 1
	if Input.is_action_pressed("Right"):
		input_velocity.x += 1
	if Input.is_action_pressed("Jump"):
		input_velocity += jump_init()
	
func jump_init():
	#Initalizer script for starting a jump, does not handle jump physics, only initiates jump sequence
	#Returns velocity to get_input()
	var jump_velocity = Vector2()
		
	#Perform jump if available
	if jump_avail and is_on_floor():
		jump_velocity.y -= 1
		jump_avail = false
	
	return jump_velocity
	
func gravity(delta):
	#Gravity physics, returns modified value to physics process to overhaul velocity.y
	
	var gravity_magnitude = velocity.y
	
	#Near the end of the jump arc, gravity's strength increases according to this function
	#Adds a feeling of weight to the end of a jump
	if gravity_magnitude < gravity_peak:
		gravity_peak_delta += delta
	else:
		gravity_peak_delta = 0
	
	if gravity_magnitude <= speed_y:
		gravity_delta += delta + (gravity_peak_delta * jump_weight)
	
	#If the player is not falling, the gravity is set to constantly be at 1, just in case the player slips off an edge
	if is_on_floor():
		gravity_delta = 0	
	
	#Check if player jumped, and resets vertical value and jump_delta
	if input_velocity.y != 0:
		gravity_magnitude = input_velocity.y * speed_y
		gravity_delta = 0
		
	gravity_magnitude -= gravity * pow(gravity_delta, 2)
		
	return gravity_magnitude
	
func movement():
	#Horizontal physics, returns modified value to physics process to overhaul velocity.x
	
	var horizontal_magnitude = velocity.x
	
	#Desired input, with drag to add a startup to horizontal movement, and a sense of momentum
	#If player is in the air and not placing inputs, maintains horizontal velocity as opposed to halting it
	if !is_on_floor():
		horizontal_magnitude = ((input_velocity.x * speed_x) / air_drag) + ((horizontal_magnitude / air_drag) * (air_drag - 1))
	else:
		horizontal_magnitude = ((input_velocity.x * speed_x) / walk_drag) + ((horizontal_magnitude / walk_drag) * (walk_drag - 1))
	
	
	return horizontal_magnitude
	
func _physics_process(delta):
	
	#Run get input before calculating physics
	get_input()
	
	#Calculate physics values for each axis individually, and overhaul previous values
	velocity.x = movement()
	velocity.y = gravity(delta)
	
	#Any calculations that invlove both axies after their modification should be placed here
	
	#Final send velocity to kinematic body
	move_and_slide(velocity, Vector2.UP) 


func throw():
	#Initializer that spawns spear object that throws it in desired direction
	pass
