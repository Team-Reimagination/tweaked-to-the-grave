extends Node

@onready var switch = AudioStreamPlayer.new()
@onready var select = AudioStreamPlayer.new()
@onready var small_select = AudioStreamPlayer.new()
@onready var slider_tick = AudioStreamPlayer.new()
var list = ["switch", "select", "small_select", "slider_tick"]

func _ready() -> void:
	for a in list:
		var b = get(a)
		add_child(b)
		b.add_to_group('Sound')
		b.stream = load("res://assets/sounds/ui/"+a+".ogg")
		b.max_polyphony = 1;
		b.bus = 'SFX';

func playMenuSound(type, onlyIfNotPlaying = false):
	var ty = get(type)
	if ty != null: 
		if (not onlyIfNotPlaying or (onlyIfNotPlaying and not ty.playing)): ty.play()
	else: print("..."+type+" does not exist.")
	
func stopMenuSound(type):
	var ty = get(type)
	if ty != null: ty.stop()
	else: print("..."+type+" does not exist.")
	
func bequietmylittlechud():
	for a in list: get(a).stop()
