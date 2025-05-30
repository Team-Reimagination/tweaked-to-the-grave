extends CanvasGroup

@onready var buttons = [$Buttons/Up, $Buttons/Down, $Buttons/Freeplay]
@onready var freeplay = $Buttons/Freeplay
@onready var fuckassSOVL = $Images
@onready var substate = $"../.."

var buttonScales = [0.0,0.0,0.0]

var selectedButton = 0
var mouseBtn = -1

static var antiterios = PlayGlobals.difficulty

func imfreeingfromthisshit():
	PlayGlobals.areWeFNFFreeDownload = !PlayGlobals.areWeFNFFreeDownload
	setFreeplay(PlayGlobals.areWeFNFFreeDownload)
	
	$"../ActionButtons".updateActions()

func setFreeplay(toFreeplay):
	freeplay.set_pressed(toFreeplay)
	$Buttons/FreeplayLabel.text = "EXTRA TO SWITCH TO\n"+("FREE PLAY" if !toFreeplay else "THE STORY")

func _ready() -> void:
	fuckassSOVL.frame = antiterios
	
	setFreeplay(PlayGlobals.areWeFNFFreeDownload)
	
	updateButtonSelection(false)
	instantScale()
	
	for butt in buttons:
		butt.mouse_entered.connect(mouse_button.bind(butt))
		butt.pressed.connect(process_button.bind())

func instantScale():
	for i in range(buttons.size()):
		buttons[i].scale.x = buttonScales[i]
		buttons[i].scale.y = buttons[i].scale.x
		
func greyButtons(fromMouse):
	var checky = fromMouse and !SaveSystem.optionsData.get("video_reducedmotions", false)
	
	for i in range(buttons.size()):
		buttons[i].self_modulate = Color(0.4,0.4,0.4) if fromMouse else Color(1.0,1.0,1.0)
		buttonScales[i] = (0.8*0.9 if checky else 0.8) if i != 2 else (0.9 if checky else 1.0);

func updateScale():
	buttonScales[selectedButton] = 0.8 if selectedButton != 2 else 1.0

func updateButtonSelection(fromMouse):
	greyButtons(fromMouse)
	buttons[selectedButton].self_modulate = Color(1.0,1.0,1.0)

func _process(_delta: float) -> void:
	for i in range(buttons.size()):
		buttons[i].scale.x = lerp(buttons[i].scale.x, buttonScales[i], 0.3)
		buttons[i].scale.y = buttons[i].scale.x
		
	if substate.canInput:
		if Input.is_action_just_pressed("Up_UI"): 
			movement(-1)
			
			selectedButton = 0
			mouseBtn = -1
			
			updatemyhardness(-1)
			scalar()
			updateButtonSelection(false)
			MenuSounds.playMenuSound('small_select')
			$"../ActionButtons".updateActions(-1)
		elif Input.is_action_just_pressed("Down_UI"):
			movement(1)
			
			selectedButton = 1
			mouseBtn = -1
			
			updatemyhardness(1)
			scalar()
			updateButtonSelection(false)
			MenuSounds.playMenuSound('small_select')
			$"../ActionButtons".updateActions()
		elif Input.is_action_just_pressed("Extra_UI"):
			selectedButton = 2
			mouseBtn = -1
			
			scalar()
			updateButtonSelection(false)
			MenuSounds.playMenuSound('small_select')
			imfreeingfromthisshit()

func movement(proposition):
	if proposition == -1:
		antiterios = (antiterios - 1) % 5
		if antiterios < 0: antiterios = 4
	else:
		antiterios = (antiterios + 1) % 5

func mouse_button(button):
	if substate.process_mode != Node.PROCESS_MODE_DISABLED:
		if mouseBtn < 0 or mouseBtn != button.get_meta("ID", 0): MenuSounds.playMenuSound('switch')
			
		mouseBtn = button.get_meta("ID", 0)
		selectedButton = mouseBtn
		updateButtonSelection(true)
		updateScale()
	
func process_button():
	if mouseBtn >= 0: MenuSounds.playMenuSound('small_select')
	
	if selectedButton != 2:
		movement(-1 if selectedButton == 0 else 1)
		updatemyhardness(-1 if selectedButton == 0 else 1)
		$"../ActionButtons".updateActions(-1 if selectedButton == 0 else 1)
	else:
		imfreeingfromthisshit()
		
	scalar()
	
func scalar():
	if !SaveSystem.optionsData.get("video_reducedmotions", false):
		buttons[selectedButton].scale *= 0.7

var swipethatshitclean;
func updatemyhardness(mymovementdirection):
	if swipethatshitclean != null:
		swipethatshitclean.kill()
	
	swipethatshitclean = get_tree().create_tween()
	if !SaveSystem.optionsData.get("video_reducedmotions", false): swipethatshitclean.tween_property(fuckassSOVL, "offset:y", 50 * mymovementdirection, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	swipethatshitclean.parallel().tween_property(fuckassSOVL, "self_modulate:a", 0.0, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	
	if !SaveSystem.optionsData.get("video_reducedmotions", false): swipethatshitclean.tween_property(fuckassSOVL, "offset:y", -50 * mymovementdirection, 0.0)
	swipethatshitclean.tween_property(fuckassSOVL, "frame", antiterios, 0.0)
	
	swipethatshitclean.tween_property(fuckassSOVL, "offset:y", 0, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	swipethatshitclean.parallel().tween_property(fuckassSOVL, "self_modulate:a", 1.0, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
