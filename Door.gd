extends Node2D

class_name Door

const Note = preload("Note.gd")
const scene_Wavelet = preload("res://Wavelet.tscn")

var locks = []
var open=false
var ignore_note_timer = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var nodes = get_children()
	for node in nodes:
		if node is Lock:
			locks.append(node)
	relock()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func open():
	open=true
	$Body.queue_free()
	$Audio_Open.play()
	for lock in locks:
		lock.hide()
		
func relock():
	for lock in locks:
		lock.lock()
		lock.deactivate()
		
	if locks.size()>=1:
		locks[0].activate()

func _on_Area2D_area_entered(area):
	if not area is Wavelet:
		return
	
	if open:
		return
	
	var key = area.note.key;
	if key in ignore_note_timer:
		return
	
	var timer = Timer.new()
	ignore_note_timer[key]=timer
	add_child(timer)
	timer.connect("timeout", self, "_on_IgnoreTimer_timeout", [key])
	timer.one_shot=true
	timer.start(0.5)
	
	var note = area.note
	var n = locks.size()
	for i in range(n):
		var lock=locks[i]
		if lock.locked:
			lock.try(note.color())
			if note.key == lock.note.key:
				lock.unlock()
				if i+1<locks.size():
					locks[i+1].activate()
			else:
				$LockTimer.start()
				$Audio_Error.play()
			break
	
	var all_unlocked=true
	for lock in locks:
		if lock.locked:
			all_unlocked=false
			break
	
	if all_unlocked: 
		open=true
		$OpenTimer.start()
		
	
func _on_IgnoreTimer_timeout(key):
	var timer = ignore_note_timer[key]
	timer.queue_free()
	ignore_note_timer.erase(key)

func _on_LockTimer_timeout():
	relock()

func _on_OpenTimer_timeout():
	$Audio_Open.play()
	open()
