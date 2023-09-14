extends KinematicBody2D
class_name Wavelet

const Note = preload("Note.gd")

const speed = 4.0

var note = Note.new("G")
var p1 = Vector2(0,100)
var p2 = Vector2(0,110)
var a1=-PI/10
var a2=PI/10
var source = null
var impulse = 10000
var energy=1.0

var merged=false
var is_Wavelet=true

func _ready():
	var p = (p1+p2)/2
	var a = a1+(fmod(a2-a1,PI)/2)
	set_global_transform(Transform2D(a,p))

func _process(delta):
	
	if merged:
		return
	
	var d = (p2-p1).length()
	if d>16:
		split()
	
	energy=energy*pow(0.25,delta)
	if energy < 0.01: 
		queue_free()
	
	p1+=Vector2(speed,0).rotated(a1);
	p2+=Vector2(speed,0).rotated(a2);
	
	var newpos = (p1+p2)/2
	var newangle = a1+(fmod(a2-a1,PI)/2)
	
	set_global_position(newpos);
	set_global_rotation(newangle);
	var oldpos = get_global_position()
	var collision = move_and_collide(newpos-oldpos)
	
	if collision !=null and collision.collider != source:
		oldpos = newpos
		newpos = get_global_position()
		var oldangle = newangle
		var colangle = collision.normal.angle()
		newangle = colangle+(colangle-oldangle)*2
		#newangle = oldangle+PI
		#newangle = colangle
		set_global_rotation(newangle);
		p1 = newpos + (p1-oldpos).rotated(newangle-oldangle)
		p2 = newpos + (p2-oldpos).rotated(newangle-oldangle)
		a1 = a1+(newangle-oldangle)
		a2 = a2+(newangle-oldangle)
		source=collision.collider
		energy = energy*1.0		# todo: depends on wall type
		# TODO: move a bit further in reflected distance
			
		
	var alpha = energy 
	var color=note.color()
	self.modulate=Color(color.r,color.g,color.b,alpha)
	
# TODO: split can cause one part of wavelet to end up in a wall, 
# causing it to pass through the wall. 
# possible solution: each wavelet actually has two seperate bodies
# that collide sepearetly. Draw one wavelet per two bodies. 
	
func split():
	queue_free()
	
	var p = (p1+p2)/2
	var a = a1+(fmod(a2-a1,PI)/2)
	
	var wavelet1 = duplicate()
	wavelet1.set_global_position((p+p1)/2)
	wavelet1.set_global_rotation(a)
	wavelet1.energy=energy/2
	wavelet1.p1 = p1
	wavelet1.p2 = p
	wavelet1.a1 = a1
	wavelet1.a2 = a
	wavelet1.source=source
	wavelet1.note=note
	wavelet1.impulse=impulse
	$"..".add_child(wavelet1)
	
	var wavelet2 = duplicate()
	wavelet1.set_global_position((p+p2)/2)
	wavelet1.set_global_rotation(a)
	wavelet2.energy=energy/2
	wavelet2.p1 = p
	wavelet2.p2 = p2
	wavelet2.a1 = a
	wavelet2.a2 = a2
	wavelet2.source=source
	wavelet2.note=note
	wavelet2.impulse=impulse
	$"..".add_child(wavelet2)
	
#
#func merge(wavelet):
#
#	var a = a1+(fmod(a2-a1,PI)/2)
#	var wa = wavelet.a1+(fmod(wavelet.a2-wavelet.a1,PI)/2)
#	var da = abs(fmod(wa-a,2*PI))
#	if da>PI/2: return
#
#	wavelet.queue_free()
#	wavelet.merged = true
#	queue_free()
#	merged = true
#
#	var wavelet2 = duplicate()
#
#	var p0 = (p1 + wavelet.p1 + p2 + wavelet.p2)/4
#	var a0 = a+(fmod(wa-a,PI)/2)
#
#	wavelet2.set_global_position(p0)
#	wavelet2.set_global_rotation(a0)
#
#	wavelet2.a1 = a0 - da
#	wavelet2.a2 = a0 + da
#	wavelet2.p1 = p0+Vector2(1,0).rotated(a1)
#	wavelet2.p2 = p0+Vector2(1,0).rotated(a2)	
#	wavelet2.energy=energy+wavelet.energy
#	wavelet2.source=null
#	#wavelet2.note=Note.new(wavelet.note.key)
#	wavelet2.note=Note.new("B")    # test
#	wavelet2.impulse=(impulse+wavelet.impulse)/2
#
#	$"..".add_child(wavelet2)
#
#
#
#func _on_Area2D_area_entered(area):
#	if merged: return
#	var parent = area.get_parent()
#	if parent:
#		if "is_Wavelet" in parent:
#			var wavelet = parent
#			if wavelet.merged: return
#			if wavelet.note.key==note.key and wavelet.source!=source:
#				merge(wavelet)
#
