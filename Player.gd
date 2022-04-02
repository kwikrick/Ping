extends RigidBody2D

class_name Player

const scene_Wavelet = preload("res://Wavelet.tscn")
const Note = preload("Note.gd")

var key = "G"

var forward_power = 1e4
var rotate_still_coefficient = 1e5
var rotate_move_coefficient = 1e2
var reverse_power = 5e3
var slide_friction_coeefficient = 300
var angular_friction_coeefficient = 2e4
var roll_friction_coeefficient = 10
var break_friction_coeefficient = 100


var impulse=Vector2(0,0)



func _ready():
	print("Player ready")
	
	
func _process(delta):
	
	if Input.is_action_just_pressed("ping"):
		
		var note = Note.new(key)
		
		var p0  = get_global_position()
		var a0 =  get_global_rotation()
		var n = 12
		for i in range(n):
			var wavelet = scene_Wavelet.instance()
			wavelet.a1 = a0 + (i*2*PI/n)
			wavelet.a2 = a0 + ((i+1)*2*PI/n)
			wavelet.p1 = p0+Vector2(1,0).rotated(wavelet.a1)
			wavelet.p2 = p0+Vector2(1,0).rotated(wavelet.a2)
			wavelet.source = self
			wavelet.note = note
			$"..".add_child(wavelet)
		#
		$AudioStreamPlayer.pitch_scale=note.pitch_scale()
		$AudioStreamPlayer.play()
		
func _physics_process(delta):
	
	set_applied_force(Vector2(0,0))
	set_applied_torque(0)
	
	add_force(Vector2(0,0),impulse*delta)
	impulse=Vector2(0,0)

	# get and compute some directions and velocities
	var angle = get_global_rotation();
	var forward = Vector2(0,-1).rotated(angle)
	var right = Vector2(1,0).rotated(angle)
	var linear_velocity = get_linear_velocity()
	var angular_velocity = get_angular_velocity()
	var forward_velocity = linear_velocity.project(forward)
	var right_velocity = linear_velocity.project(right)
	var roll_forwards = linear_velocity.dot(forward) > 0
	var forward_speed = forward_velocity.length()
	if !roll_forwards: forward_speed *= -1
	
	# control steering lef/right
	var steer = Input.get_axis("steer_left", "steer_right")
	var torque_still = steer*rotate_still_coefficient*delta 
	var torque_move = steer*rotate_move_coefficient*forward_speed*delta     
	add_torque(torque_still+torque_move)        
	
	# control forward/backward/breaking
	var accelerate = Input.get_axis("move_back", "move_forward")
	if accelerate > 0: 
		add_force(Vector2(0,0),forward*forward_power*delta)
	elif accelerate < 0: 
		add_force(Vector2(0,0),-forward*reverse_power*delta)
	
	# control breaking
	var breaking = false
	if accelerate > 0: 
		if !roll_forwards and forward_velocity.length()>10:
			breaking = true
	elif accelerate < 0: 
		if roll_forwards and forward_velocity.length()>10:
			breaking = true	
		
	# friction
	var forward_friction_coeefficient = roll_friction_coeefficient
	if breaking:
		forward_friction_coeefficient = break_friction_coeefficient
	var angular_friction_torque = -angular_velocity * angular_friction_coeefficient * delta
	var forward_friction_force = -forward_velocity * forward_friction_coeefficient * delta
	var right_friction_force = -right_velocity * slide_friction_coeefficient * delta
	
	add_force(Vector2(0,0),forward_friction_force)
	add_force(Vector2(0,0),right_friction_force)
	add_torque(angular_friction_torque)

func _on_Area2D_area_entered(area):
	if area is Wavelet and area.source!=self:
		var angle = area.get_global_rotation()
		impulse += Vector2(area.impulse,0).rotated(angle)
