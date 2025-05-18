extends Node

@onready var switch = AudioSubtitlableGeneral.new()
@onready var select = AudioSubtitlableGeneral.new()
@onready var small_select = AudioSubtitlableGeneral.new()
@onready var slider_tick = AudioSubtitlableGeneral.new()
@onready var error = AudioSubtitlableGeneral.new()
@onready var achievement_tier1 = AudioSubtitlableGeneral.new()
@onready var achievement_tier2 = AudioSubtitlableGeneral.new()
@onready var achievement_tier3 = AudioSubtitlableGeneral.new()
@onready var achievement_tier4 = AudioSubtitlableGeneral.new()
@onready var achievement_tier5 = AudioSubtitlableGeneral.new()

var list = ["switch", "select", "small_select", "slider_tick", "error", "achievement_tier1", "achievement_tier2", "achievement_tier3", "achievement_tier4", "achievement_tier5"]
var menuSubtitles = {
	"switch": "Switch Selection",
	"select": "Make Selection",
	"small_select": "Make Selection",
	"slider_tick": "Slider Tick",
	"error": "Error",
	"achievement_tier1": "Achievement Got - Tier 1",
	"achievement_tier2": "Achievement Got - Tier 2",
	"achievement_tier3": "Achievement Got - Tier 3",
	"achievement_tier4": "Achievement Got - Tier 4",
	"achievement_tier5": "Achievement Got - Tier 5",
}

var doNotPause = ["achievement_tier1", "achievement_tier2", "achievement_tier3", "achievement_tier4", "achievement_tier5"]
var alwaysProcess = ["achievement_tier1", "achievement_tier2", "achievement_tier3", "achievement_tier4", "achievement_tier5"]

func _ready() -> void:
	for a in list:
		var b = get(a)
		add_child(b)
		if (doNotPause.find(a) == -1): b.add_to_group('Sound')
		b.stream = load("res://assets/sounds/ui/"+a+".ogg")
		b.max_polyphony = 1;
		b.bus = 'SFX';
		b.subtitle = menuSubtitles[a]
		if (alwaysProcess.find(a) != -1): b.process_mode = Node.PROCESS_MODE_ALWAYS

func playMenuSound(type, onlyIfNotPlaying = false):
	var ty = get(type)
	if ty != null: 
		if (not onlyIfNotPlaying or (onlyIfNotPlaying and not ty.playing)): ty.subtitle_play()
	else: print("..."+type+" does not exist.")
	
func stopMenuSound(type):
	var ty = get(type)
	if ty != null: ty.stop()
	else: print("..."+type+" does not exist.")
	
func bequietmylittlechud():
	for a in list: get(a).stop()
