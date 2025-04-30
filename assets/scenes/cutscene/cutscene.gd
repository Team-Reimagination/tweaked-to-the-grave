extends Node2D

@onready var backgroundGradient = $BackgroundColor/Gradient
@onready var friendGroupHeads = $FriendGroupHeads
@onready var panel = $PanelBorder
@onready var dialogue = $Dialogue
@onready var timeout = $Timeout
@onready var Mmusic = $Music
@onready var panel1 = $PanelBorder/Panel1
@onready var panel2 = $PanelBorder/Panel2
@onready var camera = $Camera

var cutscene = {}
const PATH_CUTSCENE = "res://assets/data/cutscenes/"

var cutEventNum = 0;
var cutAccess = "keys"
var timeoutInitialized = false
var pressedToSkip = false
var readyToMove = false
var canInput = false
var waitForDialoguetoFinish = false
var Entirely2eaked = SaveSystem.hasWatchedCutscene()
var panelSwitchy = true

var panelPosition = Vector2(640,300)

func _ready() -> void:
	#INITIAL SETUP
	backgroundGradient.material.set("shader_parameter/Color1",Vector3(0.0,0.0,0.0))
	backgroundGradient.material.set("shader_parameter/Color2",Vector3(0.0,0.0,0.0))
	backgroundGradient.material.set("shader_parameter/Color1Alpha",0.0)
	backgroundGradient.material.set("shader_parameter/Color2Alpha",0.0)
	
	friendGroupHeads.modulate.a = 0.0
	
	panel1.modulate.a = 0.0
	panel2.modulate.a = 0.0
	
	panel.visible = false
	
	camera.zoom = Vector2(1.0,1.0)
	camera.offset = Vector2(640, 480)
	
	$Skippable.visible = Entirely2eaked
	
	if FileAccess.file_exists(PATH_CUTSCENE+PlayGlobals.cutsceneID+'.json'):
		cutscene = JSON.parse_string(FileAccess.open(PATH_CUTSCENE+PlayGlobals.cutsceneID+'.json', FileAccess.READ).get_as_text())
		
		await get_tree().create_timer(1.0).timeout
		panel.visible = true
		canInput = true
		checkCutsceneEvent()
	else :
		print("Could Not Find CUTSCENE For "+PlayGlobals.cutsceneID+'!')
	
var sinTimer = 0.0
	
func _process(delta: float) -> void:
	sinTimer += delta
	
	if panelSizeTween is not Tween or !panelSizeTween.is_valid() or !panelSizeTween.is_running(): 
		panel.size = lerp(panel.size, $ScaleRef.size, 0.3)
		panel.position.x = panelPosition.x - panel.size.x/2
		panel.position.y = panelPosition.y - panel.size.y/2
	
	panel1.position = Vector2(panel.size.x/2.0, panel.size.y/2.0)
	panel2.position = Vector2(panel.size.x/2.0, panel.size.y/2.0)
	
	if cutAccess != "keys" and timeoutInitialized and timeout.time_left <= 0 and !pressedToSkip: 
		timeoutInitialized = false
		pressedToSkip = false
		readyToMove = true
		nextEvent()
		
	var hasMoved = false
	for twee in getTweenList():
		if twee is Tween and twee.is_valid() and twee.is_running():
			hasMoved = true
			break;
	if !hasMoved: readyToMove = true

	if Entirely2eaked: $Skippable.modulate.a = 0.5 + sin(sinTimer - 1) * 0.5
	
	if !canInput and cutscene == {} and (Input.is_action_just_pressed("Accept_UI") or CustomCursor.isMouseJustPressed("left")):
		TransFuncs.switchScenes(self, PlayGlobals.getCutsceneDestination(), false, true, true)

	if cutAccess != "timeout" and canInput:
		if Input.is_action_just_pressed("Accept_UI") or CustomCursor.isMouseJustPressed('left'):
			if !readyToMove or waitForDialoguetoFinish:
				if waitForDialoguetoFinish:
					if dialogue.dialogue != {} and dialogue.typing: skipEvent()
					else:
						if !dialogue.movingOn: moveOn()
				else:
					skipEvent()
			else: moveOn()
		if Entirely2eaked and (Input.is_action_just_pressed("Back_UI") or CustomCursor.isMouseJustPressed('right')):
			cutEventNum += 2 << 10
			checkCutsceneEvent()

#CUTSCENE PROCESSOR
func nextEvent():
	cutEventNum += 1
	checkCutsceneEvent()

func moveOn():
	timeout.stop()
	readyToMove = false
	timeoutInitialized = false
	pressedToSkip = false
	waitForDialoguetoFinish = false
	nextEvent()
		
func skipEvent():
	skipTweens()
	timeout.stop()
	readyToMove = true
	timeoutInitialized = false
	pressedToSkip = true
	setPanelSize($ScaleRef.size.x, $ScaleRef.size.y, true)
	
	if waitForDialoguetoFinish: 
		dialogue.skipText()
		waitForDialoguetoFinish = false

func checkCutsceneEvent():
	if cutscene.shots.size()-1 < cutEventNum:
		ending()
	else:
		proceedWithCutscene()

func proceedWithCutscene():
	var event = cutscene.shots[cutEventNum]
	readyToMove = false
	
	cutAccess = event.nextAccess if event.has("nextAccess") else "keys"
	timeoutInitialized = true
	if event.has("timeout") and cutAccess != 'keys': timeout.start(event.timeout)
	
	for a in event.events:
		processEvent(a)

func processEvent(event):
	var timey = event.time if event.has('time') else null
	var easy = event.ease if event.has("ease") else null
	var transy = event.trans if event.has("trans") else null
	
	if event.type == 'bg_color':
		if event.has('color1'): setBGColor(event.color1[0], event.color1[1], event.color1[2], 'top', timey, easy, transy)
		if event.has('color2'): setBGColor(event.color2[0], event.color2[1], event.color2[2], 'bottom', timey, easy, transy)
	elif event.type == 'fade':
		fadeBackground(event.time, event.transRightsAreHumanRights, easy, transy)
	elif event.type == 'panel_size':
		setPanelSize(event.width, event.height, event.doScale if event.has('doScale') else false, timey, easy, transy)
	elif event.type == 'panel_position':
		movePanel(event.x, event.y, timey, easy, transy)
	elif event.type == 'background_speed':
		myHeadScrolls(event.speed, timey, easy, transy)
	elif event.type == 'load_music':
		loadMusic(event.music)
	elif event.type == 'music_volume':
		musicVolume(event.volume, timey, easy, transy)
	elif event.type == 'music_pitch':
		musicPitch(event.pitch, timey, easy, transy)
	elif event.type == 'music_switch_play':
		Mmusic.stream_paused = !Mmusic.stream_paused
	elif event.type == 'load_dialogue':
		loadDialogue(event.name)
	elif event.type == 'end_dialogue':
		dialogue.ending(false)
	elif event.type == 'next_dialogue':
		waitForDialoguetoFinish = true
		dialogue.nextDialogue()
	elif event.type == 'change_dialogue_scene':
		waitForDialoguetoFinish = true
		dialogue.dialEventNum = event.event - 1
		dialogue.nextDialogue()
	elif event.type == 'dialogue_position':
		moveDialogue(event.x, event.y, timey, easy, transy)
	elif event.type == 'load_panel':
		loadPanel(event.image, timey, easy, transy)
	elif event.type == 'camera_zoom':
		zoomCamera(event.x, event.y, timey, easy, transy)
	elif event.type == 'camera_position':
		positionCamera(event.x, event.y, timey, easy, transy)

func ending():
	for twee in getTweenList():
		if twee is Tween and twee.is_valid() and twee.is_running(): 
			twee.kill()
	
	SaveSystem.watchedCutscene()
	$Skippable.visible = false
	
	fadeBackground(1.0, 'out', 'in', 'quint')
	myHeadScrolls(friendGroupHeads.autoscroll.x * 50, 1.0, 'in', 'quint')
	movePanel(panelPosition.x, 1000, 1.0, 'in', 'quint')
	setPanelSize(0,0)
	musicVolume(0.0, 1.0, 'in', 'quint')
	if dialogue.dialogue != {}:
		dialogue.ending(true)
	
	cutscene = {}
	waitForDialoguetoFinish = false
	canInput = false
	
	await get_tree().create_timer(1.5).timeout
	TransFuncs.switchScenes(self, PlayGlobals.getCutsceneDestination(), false, true, true)
	
func skipTweens():
	for twee in getTweenList():
		if twee is Tween and twee.is_valid() and twee.is_running(): 
			twee.pause()
			twee.custom_step(999999)

#EVENTS
func getTweenList():
	return [bgFadeTween, bgColor1Tween, bgColor2Tween, bgScrollTween, panelMoveTween,
			panelSizeTween, musicVolumeTween, musicPitchTween, dialMoveTween, panelShowTween,
			camZoomTween, camMoveTween]
	
var bgFadeTween
var musicVolumeTween
var musicPitchTween
var panelSizeTween
var bgColor1Tween
var bgColor2Tween
var bgScrollTween
var panelMoveTween
var dialMoveTween
var panelShowTween
var camZoomTween
var camMoveTween

func loadMusic(music):
	Mmusic.stream = load("res://assets/music/cutscene/"+music+".ogg")
	Mmusic.play()

func setPanelSize(width, height, doScale = false, time = null, Tease = 'inout', Ttrans = 'linear'):
	$ScaleRef.size = Vector2(width, height)
	
	if doScale:
		if time == null:
			panel.size = $ScaleRef.size
			panel.position.x = panelPosition.x - panel.size.x/2
			panel.position.y = panelPosition.y - panel.size.y/2
		else:
			if panelSizeTween: bgFadeTween.kill()
			panelSizeTween = get_tree().create_tween()
			
			panelSizeTween.tween_property(panel, "size", $ScaleRef.size, time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))
			panelSizeTween.set_parallel(true).tween_property(panel, "position", Vector2(panelPosition.x - panel.size.x/2, panelPosition.y - panel.size.y/2), time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))
	
func fadeBackground(time, type = 'in', Tease = 'inout', Ttrans = 'linear'):
	if bgFadeTween: bgFadeTween.kill()
	bgFadeTween = get_tree().create_tween()
	
	bgFadeTween.tween_property(friendGroupHeads, "modulate:a", 1.0 if type == 'in' else 0.0, time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))
	bgFadeTween.set_parallel(true).tween_property(backgroundGradient.material, "shader_parameter/Color1Alpha", 1.0 if type == 'in' else 0.0, time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))
	bgFadeTween.set_parallel(true).tween_property(backgroundGradient.material, "shader_parameter/Color2Alpha", 1.0 if type == 'in' else 0.0, time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))

func setBGColor(red, green, blue, part, time = null, Tease = 'inout', Ttrans = 'linear'):
	if red > 1.0: red /= 255.0
	if green > 1.0: green /= 255.0
	if blue > 1.0: blue /= 255.0
	
	var party = str(1 if part == 'top' else 2)
	
	if time == null:
		backgroundGradient.material.set("shader_parameter/Color"+party,Vector3(red, green, blue))
	else:
		if part == 'top':
			if bgColor1Tween: bgColor1Tween.kill()
			bgColor1Tween = get_tree().create_tween()
		else:
			if bgColor2Tween: bgColor2Tween.kill()
			bgColor2Tween = get_tree().create_tween()
			
		var tweeny = bgColor1Tween if part == 'top' else bgColor2Tween
		tweeny.tween_property(backgroundGradient.material, "shader_parameter/Color"+party, Vector3(red, green, blue), time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))

func myHeadScrolls(speed, time = null, Tease = 'inout', Ttrans = 'linear'):
	if time == null:
		friendGroupHeads.autoscroll.x = speed
	else:
		if bgScrollTween: bgScrollTween.kill()
		bgScrollTween = get_tree().create_tween()
		bgScrollTween.tween_property(friendGroupHeads, "autoscroll:x", speed, time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))
		
func movePanel(xPos, yPos, time = null, Tease = 'inout', Ttrans = 'linear'):
	if time == null:
		panelPosition = Vector2(xPos, yPos)
	else:
		if panelMoveTween: panelMoveTween.kill()
		panelMoveTween = get_tree().create_tween()
		panelMoveTween.tween_property(self, "panelPosition", Vector2(xPos, yPos), time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))

func moveDialogue(xPos, yPos, time = null, Tease = 'inout', Ttrans = 'linear'):
	if time == null:
		dialogue.position = Vector2(xPos, yPos)
	else:
		if dialMoveTween: dialMoveTween.kill()
		dialMoveTween = get_tree().create_tween()
		dialMoveTween.tween_property(dialogue, "position", Vector2(xPos, yPos), time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))
		
func musicVolume(vol, time = null, Tease = 'inout', Ttrans = 'linear'):
	if time == null:
		Mmusic.volume_linear = vol
	else:
		if musicVolumeTween: musicVolumeTween.kill()
		musicVolumeTween = get_tree().create_tween()
		musicVolumeTween.tween_property(Mmusic, "volume_linear", vol, time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))
		
func musicPitch(pitch, time = null, Tease = 'inout', Ttrans = 'linear'):
	if time == null:
		Mmusic.pitch_scale = pitch
	else:
		if musicPitchTween: musicPitchTween.kill()
		musicPitchTween = get_tree().create_tween()
		musicPitchTween.tween_property(Mmusic, "pitch_scale", pitch, time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))

func loadDialogue(dial):
	waitForDialoguetoFinish = true
	dialogue.startDialogue(dial, true)
	
func loadPanel(image, time = null, Tease = 'inout', Ttrans = 'linear'):
	panelSwitchy = !panelSwitchy
	
	var pa1 = panel1 if !panelSwitchy else panel2
	var pa2 = panel1 if panelSwitchy else panel2
	
	pa2.texture = load("res://assets/images/menu/cutscene/panels/"+image+".png")
	
	if time == null:
		pa1.modulate.a = 0.0
		pa2.modulate.a = 1.0
	else:
		if panelShowTween: panelShowTween.kill()
		panelShowTween = get_tree().create_tween()
		panelShowTween.tween_property(pa1, "modulate:a", 0.0, time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))
		panelShowTween.set_parallel(true).tween_property(pa2, "modulate:a", 1.0, time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))

func zoomCamera(xPos, yPos, time = null, Tease = 'inout', Ttrans = 'linear'):
	if time == null:
		camera.zoom = Vector2(xPos, yPos)
	else:
		if camZoomTween: camZoomTween.kill()
		camZoomTween = get_tree().create_tween()
		camZoomTween.tween_property(camera, "zoom", Vector2(xPos, yPos), time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))
		
func positionCamera(xPos, yPos, time = null, Tease = 'inout', Ttrans = 'linear'):
	if time == null:
		camera.position = Vector2(xPos, yPos)
	else:
		if camMoveTween: camMoveTween.kill()
		camMoveTween = get_tree().create_tween()
		camMoveTween.tween_property(camera, "position", Vector2(xPos, yPos), time).set_ease(PlayGlobals.getEaseType(Tease)).set_trans(PlayGlobals.getTransType(Ttrans))
