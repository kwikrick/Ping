extends StaticBody2D

class_name FixedTransponder

const scene_Wavelet = preload("res://Wavelet.tscn") 
const Note = preload("Note.gd")

export var transmit_key = "A"
export var receive_key = "G"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ready=true
var impulse=Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Transmitter.modulate = Note.new(transmit_key).color()
	$Receiver.modulate = Note.new(receive_key).color()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func ping():
	if ready==false:
		return
		
	ready=false
	$Timer.start()
	
	var note = Note.new(transmit_key)
	
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

	
func _on_Area2D_body_entered(body):
	if body is Wavelet:
		var wave=body
		if wave.source!=self:
			wave.queue_free()
			if wave.note.key == receive_key:
				ping()

func _on_Timer_timeout():
	ready=true
	

