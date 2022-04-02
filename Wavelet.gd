extends KinematicBody2D
class_name Wavelet

const Note = preload("Note.gd")

const max_age = 1.0
const speed = 4.0

var note = Note.new("G")
var p1 = Vector2(0,100)
var p2 = Vector2(0,110)
var a1=-PI/10
var a2=PI/10
var source = null
var impulse = 10000
var age = 0.0
var energy=1.0


func _ready():
	var p = (p1+p2)/2
	var a = a1+(fmod(a2-a1,PI)/2)
	set_global_transform(Transform2D(a,p))

func _process(delta):
	
	var d = (p2-p1).length()
	if d>16:
		split()
	
	age+=delta
	#if age > max_age:
	#	queue_free()
	
	energy=energy*pow(0.25,delta)
	if energy < 0.01: 
		queue_free()
			
	#var angle = get_global_rotation();
	#var forward = Vector2(1,0).rotated(angle)
	
	p1+=Vector2(speed,0).rotated(a1);
	p2+=Vector2(speed,0).rotated(a2);
	
	var newpos = (p1+p2)/2
	var newangle = a1+(fmod(a2-a1,PI)/2)
	
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
		# move a bit further
		
		
	
	#var alpha = 1.0-(age/max_age)
	var alpha = energy 
	var color=note.color()
	self.modulate=Color(color.r,color.g,color.b,alpha)
	
func split():
	queue_free()
	
	var p = (p1+p2)/2
	var a = a1+(fmod(a2-a1,PI)/2)
	
	var wavelet1 = duplicate()
	wavelet1.age=age
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
	wavelet2.age=age
	wavelet2.energy=energy/2
	wavelet2.p1 = p
	wavelet2.p2 = p2
	wavelet2.a1 = a
	wavelet2.a2 = a2
	wavelet2.source=source
	wavelet2.note=note
	wavelet2.impulse=impulse
	$"..".add_child(wavelet2)
	


#func _on_Wavelet_body_entered(body):
#	if body != source:
#		queue_free()
	
