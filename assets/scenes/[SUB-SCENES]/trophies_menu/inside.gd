extends CanvasLayer

static var selectedColumn = 0
static var selectedRow = 0

@onready var substate = $".."

var trophies = [[]]
var trophyScales = [[]]

var mouseBtn = -1
@onready var buttons = [$Buttons/Up, $Buttons/Down]
var buttonScales = [1.0,1.0]
var selectedButton = 0

func _ready() -> void:
	var referenceTrophy = $TrophyHolders/TPR
	
	var curRow = 0
	var curColumn = 0
	
	for a in AchievementFuncs.achievementTable.keys():
		var tro : TextureButton = referenceTrophy.duplicate()
			
		$TrophyHolders.add_child(tro)
		tro.visible = true
		tro.texture_normal = load("res://assets/images/achievements/"+a+".png")
			
		if curColumn > 4:
			curColumn = 0
			curRow += 1
			
			trophies.push_back([])
			trophyScales.push_back([])
			
		tro.name = a
		tro.set_meta("row", curRow)
		tro.set_meta("column", curColumn)
		tro.mouse_filter = Control.MOUSE_FILTER_PASS
			
		trophies[curRow].push_back(tro)
		trophyScales[curRow].push_back(1.0)
			
		tro.global_position = referenceTrophy.global_position + Vector2(117 * curColumn, 117 * curRow)
		tro.mouse_entered.connect(mouseTrophy.bind(tro))
			
		curColumn += 1
	
	updateTrophySelection()
	updateTrophyScale()
	instantTrophyScale()
	
	updateButtonSelection(false)
	instantScale()
	
	for butt in buttons:
		butt.mouse_entered.connect(mouse_button.bind(butt))
		butt.pressed.connect(process_button.bind())

func mouseTrophy(button):
	if substate.process_mode != Node.PROCESS_MODE_DISABLED:
		if selectedColumn != button.get_meta("column", 0) or selectedRow != button.get_meta("row", 0): MenuSounds.playMenuSound('switch')
			
		selectedColumn = button.get_meta("column", 0)
		selectedRow = button.get_meta("row", 0)
		
		updateTrophySelection()
		updateTrophyScale()

func instantTrophyScale():
	for i in range(trophies.size()):
		for j in range(trophies[i].size()):
			trophies[i][j].scale.x = trophyScales[i][j]
			trophies[i][j].scale.y = trophies[i][j].scale.x
		
func greyTrophies():
	for i in range(trophies.size()):
		for j in range(trophies[i].size()):
			trophies[i][j].self_modulate = Color(0.0,0.0,0.0) if !AchievementFuncs.hasItUnlocked(trophies[i][j].name) else Color(0.6,0.6,0.6)
			trophyScales[i][j] = 0.9 if !SaveSystem.optionsData.get("video_reducedmotions", false) else 1.0;

func updateTrophyScale():
	trophyScales[selectedRow][selectedColumn] = 1.0

func updateTrophySelection():
	greyTrophies()
	trophies[selectedRow][selectedColumn].self_modulate = Color(1.0,1.0,1.0) if AchievementFuncs.hasItUnlocked(trophies[selectedRow][selectedColumn].name) else Color(0.0,0.0,0.0)
	
	var exists = trophies[selectedRow][selectedColumn].name in AchievementFuncs.achievementTable
	var unlocker = AchievementFuncs.hasItUnlocked(trophies[selectedRow][selectedColumn].name)
	
	if exists:
		var achy = AchievementFuncs.achievementTable[trophies[selectedRow][selectedColumn].name]
		
		$Name.text = achy.name if unlocker else "ACHIEVEMENT LOCKED"
		$Desc.text = achy.desc
		$BigTrophy.texture = load("res://assets/images/achievements/"+trophies[selectedRow][selectedColumn].name+"-large.png")
	else:
		$Name.text = "Doesn't exist?????"
		$Desc.text = "Either the achievement doesn't exist, or something fucked up."
	
	$BigTrophy.self_modulate = Color(1.0,1.0,1.0) if unlocker else Color(0.0,0.0,0.0)

func _process(_delta: float) -> void:
	for i in range(trophies.size()):
		for j in range(trophies[i].size()):
			trophies[i][j].scale.x = lerp(trophies[i][j].scale.x, trophyScales[i][j], 0.3)
			trophies[i][j].scale.y = trophies[i][j].scale.x
	
	for i in range(buttons.size()):
		buttons[i].scale.x = lerp(buttons[i].scale.x, buttonScales[i], 0.3)
		buttons[i].scale.y = buttons[i].scale.x
	
	if substate.canInput:
		if Input.is_action_just_pressed("Up_UI"): 
			mouseBtn = -1
			selectedButton = 0
			
			movement(-1)
			
			scalar()
			updateTrophySelection()
			updateTrophyScale()
			
			updateButtonSelection(false)
			updateScale()
			
			MenuSounds.playMenuSound('switch')
		elif Input.is_action_just_pressed("Down_UI"):
			mouseBtn = -1
			selectedButton = 1
			
			movement(1)
			
			scalar()
			updateTrophySelection()
			updateTrophyScale()
			
			updateButtonSelection(false)
			updateScale()
			
			MenuSounds.playMenuSound('switch')
		elif Input.is_action_just_pressed("Left_UI"): 
			mouseBtn = -1
			
			selectedColumn -= 1
			if selectedColumn < 0: selectedColumn = trophies[selectedRow].size() - 1
			
			updateTrophySelection()
			updateTrophyScale()
			MenuSounds.playMenuSound('switch')
			
			updateButtonSelection(false)
			updateScale()
		elif Input.is_action_just_pressed("Right_UI"):
			mouseBtn = -1
			
			selectedColumn = (selectedColumn + 1) % trophies[selectedRow].size()
			
			updateTrophySelection()
			updateTrophyScale()
			MenuSounds.playMenuSound('switch')
			
			updateButtonSelection(false)
			updateScale()
			
func scalar():
	if !SaveSystem.optionsData.get("video_reducedmotions", false):
		buttons[selectedButton].scale *= 0.7

func instantScale():
	for i in range(buttons.size()):
		buttons[i].scale.x = buttonScales[i]
		buttons[i].scale.y = buttons[i].scale.x
		
func greyButtons(fromMouse):
	var checky = fromMouse and !SaveSystem.optionsData.get("video_reducedmotions", false)
	
	for i in range(buttons.size()):
		buttons[i].self_modulate = Color(0.4,0.4,0.4) if fromMouse else Color(1.0,1.0,1.0)
		buttonScales[i] = 0.9 if checky else 1.0;

func updateScale():
	buttonScales[selectedButton] = 1.0

func updateButtonSelection(fromMouse):
	greyButtons(fromMouse)
	buttons[selectedButton].self_modulate = Color(1.0,1.0,1.0)

func mouse_button(button):
	if substate.process_mode != Node.PROCESS_MODE_DISABLED:
		if mouseBtn < 0 or mouseBtn != button.get_meta("ID", 0): MenuSounds.playMenuSound('switch')
			
		mouseBtn = button.get_meta("ID", 0)
		selectedButton = mouseBtn
		updateButtonSelection(true)
		updateScale()

func movement(dir):
	if dir == -1:
		selectedRow -= 1
		if selectedRow < 0: selectedRow = trophies.size() - 1
	else:
		selectedRow = (selectedRow + 1) % trophies.size()
		
	if selectedColumn >= trophies[selectedRow].size(): selectedColumn = trophies[selectedRow].size() - 1

func process_button():
	if mouseBtn >= 0: MenuSounds.playMenuSound('small_select')
	
	movement(-1 if selectedButton == 0 else 1)
	scalar()
	
	updateTrophySelection()
	updateTrophyScale()
