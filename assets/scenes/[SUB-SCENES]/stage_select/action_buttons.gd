extends Node

@onready var substate = $"../.."
@onready var difficulty = $"../Difficulty"
@onready var saveRow = [$Save/Buttons/New, $Save/Buttons/Resume, $Save/Buttons/Delete]

var levels = ['SHR','SHR','SHR','SHR','SHR','SHR','SHR','SHR','SHR','SHR']
var levelRow = []

var surely = preload("res://assets/scenes/[SUB-SCENES]/question_menu/question_menu.tscn")

var currentRow
var curGroup
var otherGroup

static var curSelected = 0
var buttonScales = []

@onready var mouseBTNS = [$Levels/Left, $Levels/Right, $Levels/Play]
var mouseButton = -1
var mouseScales = [0.0,0.0,0.0]

var visiTween

#SAVE ACTION VARIABLES
var saveComplete = false
var saveStarted = false

var curSave = {}

var levelButton = load("res://assets/scenes/[SUB-SCENES]/level_holder/level_holder.tscn")

func _ready() -> void:
	for a in range(levels.size()):
		var b = levelButton.instantiate()
		$Levels/Renderer/Group.add_child(b)
		b.create(levels[a])
		b.set_meta("ID", a)
		
		b.position.x += (b.get_child(2).size.x + 30) * a
		b.position.y = $Levels/Renderer.size.y / 2.0 - b.get_child(2).size.y/1.78
		levelRow.append(b)
	
	setUpRows()

	for butt in saveRow:
		butt.mouse_entered.connect(mouse_button.bind(butt))
		butt.pressed.connect(process_button.bind())
	for butt in mouseBTNS:
		butt.mouse_entered.connect(mouse_mouse_button.bind(butt))
		butt.pressed.connect(process_mouse_button.bind())

func instantScale():
	for i in range(currentRow.size()):
		currentRow[i].scale.x = buttonScales[i]
		currentRow[i].scale.y = currentRow[i].scale.x
	
	for i in range(mouseBTNS.size()):
		mouseBTNS[i].scale.x = mouseScales[i]
		mouseBTNS[i].scale.y = mouseBTNS[i].scale.x

func greyButtons():
	for i in range(currentRow.size()):
		currentRow[i]["self_modulate" if !PlayGlobals.areWeFNFFreeDownload else "modulate"] = Color(0.4,0.4,0.4)
		if substate.canInput: buttonScales[i] = 0.9 if !PlayGlobals.areWeFNFFreeDownload else 1.0;

func updateScale():
	buttonScales[curSelected] = 1.0 if !PlayGlobals.areWeFNFFreeDownload else 1.15

func updateButtonSelection():
	greyButtons()
	if curSelected != 0 and !saveStarted and !PlayGlobals.areWeFNFFreeDownload: pass
	else: currentRow[curSelected]["self_modulate" if !PlayGlobals.areWeFNFFreeDownload else "modulate"] = Color(1.0,1.0,1.0)

func updateMiceButtons():
	for i in range(mouseBTNS.size()):
		mouseBTNS[i].self_modulate = Color(0.4,0.4,0.4) if mouseButton != -1 else Color(1.0,1.0,1.0)
		if substate.canInput: mouseScales[i] = 0.9 if mouseButton != -1 else 1.0;
	
	if mouseButton != -1:
		mouseBTNS[mouseButton].self_modulate = Color(1.0,1.0,1.0)
		mouseScales[mouseButton] = 1.0

func setUpRows():
	currentRow = levelRow if PlayGlobals.areWeFNFFreeDownload else saveRow
	curGroup = $Levels if PlayGlobals.areWeFNFFreeDownload else $Save
	otherGroup = $Save if PlayGlobals.areWeFNFFreeDownload else $Levels
	
	buttonScales = []
	for i in range(currentRow.size()): buttonScales.append(0.0)
	
	if curSelected >= currentRow.size(): curSelected = currentRow.size() - 1
	elif curSelected < 0: curSelected = 0
	
	curGroup.position.x = 0.0
	otherGroup.position.x = 1 << 13
	
	if PlayGlobals.areWeFNFFreeDownload: #LEVEL ACTIONS
		moveLevelRow(false)
		
		for a in levelRow:
			a.applyScore(difficulty.antiterios)
	else: #SAVE ACTIONS
		saveStarted = SaveSystem.saveData.difficulties.has(str(difficulty.antiterios))
		
		if saveStarted:
			SaveSystem.curDifficultySave = SaveSystem.saveData.difficulties[str(difficulty.antiterios)]
			curSave = SaveSystem.curDifficultySave
			saveComplete = curSave.levelInitials == "complete"
		else:
			saveComplete = false
			curSave = {}
		
		$Save/Buttons/Resume.texture_normal = load("res://assets/images/menu/stageselect/save_resume_complete.png") if saveComplete else load("res://assets/images/menu/stageselect/save_resume.png")
		
		$Save/LivesLabel.text = "x"+str(curSave.lives) if curSave != {} else "x??"
		$Save/HealthLabel.text = "x"+str(curSave.health) if curSave != {} else "x?"
		$Save/LiraLabel.text = str(curSave.lira) if curSave != {} else "??"
		$Save/LevelLabel.text = "LV "+str(curSave.level) if curSave != {} else "LV ?"
		$Save/LevelText.text = curSave.levelName if curSave != {} else "NOT STARTED"
		
	updateButtonSelection()
	updateScale()
	
	updateMiceButtons()
	instantScale()

func updateActions(movement = 1):
	visiTween = get_tree().create_tween()
	visiTween.tween_property(curGroup, "modulate:a", 0.0, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	visiTween.set_parallel(true).tween_property(curGroup, "position:y", 50 * movement, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	
	await visiTween.finished
	visiTween.stop()
	visiTween = get_tree().create_tween()
	setUpRows()
	curGroup.position.y = -50 * movement
	visiTween.tween_property(curGroup, "modulate:a", 1.0, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	visiTween.set_parallel(true).tween_property(curGroup, "position:y", 0, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)

func moveLevelRow(doLerp):
	var positionToLookFor = max(min(-levelRow[curSelected].position.x + $Levels/Renderer.size.x/2 - levelRow[curSelected].get_child(2).size.x / 2.0, levelRow[0].position.x + 30), -1 * (levelRow[levelRow.size()-1].position.x - $Levels/Renderer.size.x + levelRow[0].get_child(2).size.x + 30))
	$Levels/Renderer/Group.position.x = lerp($Levels/Renderer/Group.position.x, positionToLookFor, 0.2) if doLerp else positionToLookFor

func movementPropositions(move):
	curSelected = (curSelected + move) % currentRow.size()
	if curSelected < 0: curSelected = currentRow.size()-1
	
	updateButtonSelection()
	updateScale()

func _process(_delta: float) -> void:
	for i in range(currentRow.size()):
		currentRow[i].scale.x = lerp(currentRow[i].scale.x, buttonScales[i], 0.3)
		currentRow[i].scale.y = currentRow[i].scale.x
		
	for i in range(mouseBTNS.size()):
		mouseBTNS[i].scale.x = lerp(mouseBTNS[i].scale.x, mouseScales[i], 0.3)
		mouseBTNS[i].scale.y = mouseBTNS[i].scale.x
			
	if PlayGlobals.areWeFNFFreeDownload:
		moveLevelRow(true)
			
	if substate.canInput:
		if Input.is_action_just_pressed("Left_UI"): 
			MenuSounds.playMenuSound('switch')
			movementPropositions(-1)
			
			mouseButton = -1
			updateMiceButtons()
			scalar(mouseBTNS[0])
		elif Input.is_action_just_pressed("Right_UI"):
			MenuSounds.playMenuSound('switch')
			movementPropositions(1)
			
			mouseButton = -1
			updateMiceButtons()
			scalar(mouseBTNS[1])
		if Input.is_action_just_pressed("Accept_UI"):
			process_button()

func mouse_button(button):
	if substate.canInput and substate.process_mode != Node.PROCESS_MODE_DISABLED:
		if curSelected != button.get_meta("ID", 0): MenuSounds.playMenuSound('switch')
		
		curSelected = button.get_meta("ID", 0)
		updateButtonSelection()
		updateScale()

func mouse_mouse_button(button):
	if substate.canInput and substate.process_mode != Node.PROCESS_MODE_DISABLED:
		if mouseButton != button.get_meta("ID", 0): MenuSounds.playMenuSound('switch')
		
		mouseButton = button.get_meta("ID", 0)
		updateMiceButtons()

func process_mouse_button():
	if mouseButton < 2:
		MenuSounds.playMenuSound('small_select')
		movementPropositions(1 if mouseButton == 1 else -1)
		updateMiceButtons()
		scalar(mouseBTNS[mouseButton])
	else:
		propose()

func process_button():
	if substate.canInput:
		if !PlayGlobals.areWeFNFFreeDownload:
			if curSelected != 0 and !saveStarted: MenuSounds.playMenuSound("error")
			else:
				if curSelected == 0:
					if !saveStarted: substate.moveOn(false)
					else: 
						if !saveComplete: areyouSure() 
						else: confirmNew()
				elif curSelected == 1: 
					if !saveComplete: substate.moveOn(false)
					else: MenuSounds.playMenuSound("error")
				else: 
					if !saveComplete: areyouSure()
					else: confirmNew()
		else:
			propose()

func propose():
	if levelRow[curSelected].get_meta("locked"): MenuSounds.playMenuSound("error")
	else:
		substate.moveOn(false)
		PlayGlobals.levelID = levelRow[curSelected].get_meta("level")

func areyouSure():
	substate.process_mode = Node.PROCESS_MODE_DISABLED
	var gama = surely.instantiate()
	PlayGlobals.addSubstate(self, gama)

func confirmNew():
	substate.process_mode = Node.PROCESS_MODE_ALWAYS
	MenuSounds.playMenuSound("select")
	
	if !PlayGlobals.areWeFNFFreeDownload:
		if curSelected == 0 and saveStarted:
			SaveSystem.eraseCurrentGameplaySave(difficulty.antiterios)
			substate.moveOn(false)
		elif curSelected == 2:
			SaveSystem.eraseCurrentGameplaySave(difficulty.antiterios)
			updateActions()

func scalar(button):
	button.scale *= 0.7

func noToTheNew():
	substate.process_mode = Node.PROCESS_MODE_ALWAYS
