extends Node

class_name Note

var key = "A"
var octave = 0

const base_freq = 440

const key2freq = {"A":440, "B":493.88, "C":523.25, "D":587.33, "E":659.25, "F":698.46, "G":783.99}

const key2color = {"A":Color(1,0,0), "B":Color(0,1,0), "C":Color(1,1,0), "D":Color(0,0,1), "E":Color(1,0,1), "F":Color(0,1,1), "G":Color(1,1,1)}

func pitch_scale():
	return key2freq[key.to_upper()] / base_freq * pow(2,octave)

func color():
	return key2color[key.to_upper()]
	
func _init(letter, oct=0): 
	key = letter.to_upper()
	octave = oct


