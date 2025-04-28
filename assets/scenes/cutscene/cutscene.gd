extends Node2D

@onready var backgroundGradient = $BackgroundColor/Gradient
@onready var friendGroupHeads = $FriendGroupHeads
@onready var panel = $PanelBorder
@onready var timeout = $Timeout
@onready var music = $Music

var cutscene = {}
const PATH_CUTSCENE = "res://assets/data/cutscenes/"

var cutEventNum = 0;
var cutAccess = "keys"
var timeoutInitialized = false
var pressedToSkip = false
var readyToMove = false
var canInput = true

var panelPosition = Vector2(640,480)

func _ready() -> void:
	#INITIAL SETUP
	backgroundGradient.material.set("shader_parameter/Color1",Vector3(0.0,0.0,0.0))
	backgroundGradient.material.set("shader_parameter/Color2",Vector3(0.0,0.0,0.0))
	backgroundGradient.material.set("shader_parameter/Color1Alpha",0.0)
	backgroundGradient.material.set("shader_parameter/Color2Alpha",0.0)
	
	friendGroupHeads.modulate.a = 0.0
	
	panel.visible = false
	
	if FileAccess.file_exists(PATH_CUTSCENE+PlayGlobals.cutsceneID+'.json'):
		cutscene = JSON.parse_string(FileAccess.open(PATH_CUTSCENE+PlayGlobals.cutsceneID+'.json', FileAccess.READ).get_as_text())
		
		await get_tree().create_timer(1.0).timeout
		panel.visible = true
		checkCutsceneEvent()
	else :
		print("Could Not Find CUTSCENE For "+PlayGlobals.cutsceneID+'!')
	
func _process(_delta: float) -> void:
	if panelSizeTween is not Tween or !panelSizeTween.is_valid() or !panelSizeTween.is_running(): 
		panel.size = lerp(panel.size, $ScaleRef.size, 0.3)
		panel.position.x = panelPosition.x - panel.size.x/2
		panel.position.y = panelPosition.y - panel.size.y/2
	
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

	if cutAccess != "timeout" and canInput:
		if Input.is_action_just_pressed("Accept_UI") or CustomCursor.isMouseJustPressed('left'):
			if !readyToMove: skipEvent()
			else: moveOn()
		if Input.is_action_just_pressed("Back_UI") or CustomCursor.isMouseJustPressed('right'):
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
	nextEvent()
		
func skipEvent():
	skipTweens()
	timeout.stop()
	readyToMove = true
	timeoutInitialized = false
	pressedToSkip = true
	setPanelSize($ScaleRef.size.x, $ScaleRef.size.y, true)

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
	if event.type == 'fade':
		fadeBackground(event.time, event.transRightsAreHumanRights, easy, transy)
	if event.type == 'panel_size':
		setPanelSize(event.width, event.height, event.doScale if event.has('doScale') else false, timey, easy, transy)
	if event.type == 'panel_position':
		movePanel(event.x, event.y, event.time if event.has('time') else null, easy, transy)
	if event.type == 'background_speed':
		myHeadScrolls(event.speed, event.time if event.has('time') else null, easy, transy)

func ending():
	fadeBackground(1.0, 'out', 'in', 'quint')
	myHeadScrolls(-1000, 1.0, 'in', 'quint')
	movePanel(panelPosition.x, 1000, 1.0, 'in', 'quint')
	setPanelSize(0,0)
	
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
	return [bgFadeTween, bgColor1Tween, bgColor2Tween, bgScrollTween, panelMoveTween, panelSizeTween]
	
var bgFadeTween
var panelSizeTween
var bgColor1Tween
var bgColor2Tween
var bgScrollTween
var panelMoveTween

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
		var tweeny = bgColor1Tween if part == 'top' else bgColor2Tween
		if tweeny: tweeny.kill()
		tweeny = get_tree().create_tween()
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
