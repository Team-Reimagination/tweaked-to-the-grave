extends CanvasLayer

var subtitulars = []
var subtitularNodes = []
var subtitularTweens = []
var subtitularYs = []
@onready var backg = load("res://assets/data/subtitle_background.stylebox")

var usualPlacement = Vector2(1280,850)

func setPlacementY(num = null):
	usualPlacement.y = num if num != null else 850
	
func setPlacementX(num = null):
	usualPlacement.x = num if num != null else 1280
	
func _ready() -> void:
	layer = 126
	process_mode = Node.PROCESS_MODE_ALWAYS

func addSubtitle(subtitle):
	var subLabel : Label
	var subNum
	
	if subtitulars.find(subtitle) != -1:
		subLabel = subtitularNodes[subtitulars.find(subtitle)]
	else:
		subLabel = Label.new()
		add_child(subLabel)
		subLabel.text = "- ["+subtitle+"]"
		
		subLabel.label_settings = LabelSettings.new()
		subLabel.label_settings.font = load("res://assets/fonts/CrookedLogs.ttf")
		subLabel.label_settings.font_size = 16
		subLabel.label_settings.font_color = Color(1.0,1.0,1.0,1.0)
		subLabel.label_settings.outline_size = 8
		subLabel.label_settings.outline_color = Color(0.0,0.0,0.0,1.0)
		
		subLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		subLabel.size = subLabel.label_settings.font.get_string_size(subLabel.text, HORIZONTAL_ALIGNMENT_CENTER, -1, subLabel.label_settings.font_size) + Vector2(15,10)
		
		subLabel.set("theme_override_styles/normal", backg)
		
		subtitularNodes.push_back(subLabel)
		subtitulars.push_back(subtitle)
	
	subNum = subtitulars.find(subtitle)
	
	var tweeny = get_tree().create_tween()
	
	if subtitularTweens.size() > subNum:
		if subtitularTweens[subNum]:
			subtitularTweens[subNum].stop()
		
		subLabel.modulate.a = 1.0
		subtitularTweens[subNum] = tweeny
	else:
		subtitularTweens.push_back(tweeny)
		subtitularYs.push_back(0.0)
		subLabel.position = usualPlacement - Vector2(subLabel.size.x, subLabel.size.y/2)
	
	tweeny.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(subLabel, "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART).set_delay(3.0)
	
	adjustYPoses()
	
func _process(_delta: float) -> void:
	for a in subtitularNodes.size():
		if subtitularNodes[a] != null:
			var lerpo = 0.2 if !SaveSystem.optionsData.get("video_reducedmotions", false) else 1.0
			
			subtitularNodes[a].position.y = lerp(subtitularNodes[a].position.y, usualPlacement.y - subtitularNodes[a].size.y/2 + subtitularYs[a], lerpo)
			subtitularNodes[a].position.x = lerp(subtitularNodes[a].position.x, usualPlacement.x - subtitularNodes[a].size.x, lerpo)
			
			if subtitularNodes[a].modulate.a <= 0.001:
				subtitularNodes[a].queue_free()
				subtitularNodes.remove_at(a)
				subtitularTweens.remove_at(a)
				subtitulars.remove_at(a)
				subtitularYs.remove_at(a)
				
				adjustYPoses()
				break

func adjustYPoses():
	if subtitularYs.size() == 0: return
	
	subtitularYs[subtitularYs.size() - 1] = 0.0
	
	for a in subtitularYs.size():
		if a > 0:
			subtitularYs[subtitularYs.size() - 1 - a] = subtitularYs[subtitularYs.size() - a] - subtitularNodes[subtitularYs.size() - a].size.y

func clearSubtitles():
	for a in subtitularTweens:
		if a != null: a.kill()
	for a in subtitularNodes:
		if a != null: a.queue_free()
	
	subtitulars = []
	subtitularNodes = []
	subtitularTweens = []
	subtitularYs = []
