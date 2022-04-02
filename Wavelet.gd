extends Area2D
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
var impulse = 100000
var age = 0.0


func _ready():
	var p = (p1+p2)/2
	var a = a1+(fmod(a2-a1,PI)/2)
	set_global_transform(Transform2D(a,p))

func _process(delta):
	
	var d = (p2-p1).length()
	if d>16:
		split()
	
	age+=delta
	
	if age > max_age:
		queue_free()
			
	#var angle = get_global_rotation();
	#var forward = Vector2(1,0).rotated(angle)
	
	p1+=Vector2(speed,0).rotated(a1);
	p2+=Vector2(speed,0).rotated(a2);
	
	var p = (p1+p2)/2
	var a = a1+(fmod(a2-a1,PI)/2)
	set_global_transform(Transform2D(a,p))
	
	var alpha = 1.0-(age/max_age) 
	var color=note.color()
	self.modulate=Color(color.r,color.g,color.b,alpha)
	
func split():
	queue_free()
	
	var p = (p1+p2)/2
	var a = a1+(fmod(a2-a1,PI)/2)
	
	var wavelet1 = duplicate()
	wavelet1.age=age
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
	wavelet2.p1 = p
	wavelet2.p2 = p2
	wavelet2.a1 = a
	wavelet2.a2 = a2
	wavelet2.source=source
	wavelet2.note=note
	wavelet2.impulse=impulse
	$"..".add_child(wavelet2)
	


func _on_Wavelet_body_entered(body):
	if body != source:
		queue_free()
	
