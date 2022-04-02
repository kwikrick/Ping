extends Node2D

const Note = preload("Note.gd")

class_name Lock

export var key = "A"

var locked=true
var note = Note.new(key)

# Called when the node enters the scene tree for the first time.
func _ready():
	note = Note.new(key)
	$ColorPatch.color = note.color()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func try(color):
	$LockPatch.color = color

func unlock():
	$LockPatch.color = note.color()
	if locked:
		locked=false
		$Audio_Unlock.play()

func lock():
	$LockPatch.color = Color(0,0,0)
	if not locked:
		locked=true
		$Audio_Unlock.play()

func activate():
	$LockPatch.show()
	
func deactivate():
	$LockPatch.hide()
