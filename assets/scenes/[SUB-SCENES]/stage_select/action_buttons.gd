extends Node

@onready var substate = $"../.."
@onready var difficulty = $"../Difficulty"
@onready var saveRow = [$Save/Buttons/New, $Save/Buttons/Resume, $Save/Buttons/Delete]
@onready var levelRow = []

var surely = preload("res://assets/scenes/[SUB-SCENES]/question_menu/question_menu.tscn")

var currentRow
var curGroup
var otherGroup

var curSelected = 0
var buttonScales = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]

var visiTween

#SAVE ACTION VARIABLES
var saveComplete = false
var saveStarted = false

var curSave = {}

func _ready() -> void:
	setUpRows()

	for butt in saveRow:
		butt.mouse_entered.connect(mouse_button.bind(butt))
		butt.pressed.connect(process_button.bind())
	for butt in levelRow:
		butt.mouse_entered.connect(mouse_button.bind(butt))
		butt.pressed.connect(process_button.bind())

func instantScale():
	for i in range(currentRow.size()):
		currentRow[i].scale.x = buttonScales[i]
		currentRow[i].scale.y = currentRow[i].scale.x

func greyButtons():
	for i in range(currentRow.size()):
		currentRow[i].self_modulate = Color(0.4,0.4,0.4)
		if substate.canInput: buttonScales[i] = 0.9;

func updateScale():
	buttonScales[curSelected] = 1.0

func updateButtonSelection():
	greyButtons()
	if curSelected != 0 and !saveStarted and !PlayGlobals.areWeFNFFreeDownload: pass
	else: currentRow[curSelected].self_modulate = Color(1.0,1.0,1.0)

func setUpRows():
	currentRow = levelRow if PlayGlobals.areWeFNFFreeDownload else saveRow
	curGroup = $Levels if PlayGlobals.areWeFNFFreeDownload else $Save
	otherGroup = $Save if PlayGlobals.areWeFNFFreeDownload else $Levels
	
	if curSelected >= currentRow.size(): curSelected = currentRow.size - 1
	elif curSelected < 0: curSelected = 0
	
	curGroup.position.x = 0.0
	otherGroup.position.x = 1 << 13
	
	if PlayGlobals.areWeFNFFreeDownload: #LEVEL ACTIONS
		pass
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

func _process(_delta: float) -> void:
	for i in range(currentRow.size()):
		currentRow[i].scale.x = lerp(currentRow[i].scale.x, buttonScales[i], 0.3)
		currentRow[i].scale.y = currentRow[i].scale.x
			
	if substate.canInput:
		if Input.is_action_just_pressed("Left_UI"): 
			curSelected = (curSelected - 1) % currentRow.size()
			if curSelected < 0: curSelected = currentRow.size()-1
			updateButtonSelection()
			updateScale()
			MenuSounds.playMenuSound('switch')
		elif Input.is_action_just_pressed("Right_UI"):
			curSelected = (curSelected + 1) % currentRow.size()
			updateButtonSelection()
			updateScale()
			MenuSounds.playMenuSound('switch')
		
		if Input.is_action_just_pressed("Accept_UI"):
			process_button()

func mouse_button(button):
	if substate.canInput and substate.process_mode != Node.PROCESS_MODE_DISABLED:
		if curSelected != button.get_meta("ID", 0): MenuSounds.playMenuSound('switch')
		
		curSelected = button.get_meta("ID", 0)
		updateButtonSelection()
		updateScale()

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

func noToTheNew():
	substate.process_mode = Node.PROCESS_MODE_ALWAYS
