extends Parallax2D

@onready var buttons = [$Buttons/Adventure, $Buttons/Trophies, $Buttons/Options, $Buttons/Credits]
@onready var graveHand = $Hand
@onready var scene = get_tree().current_scene

var stageSel = load("res://assets/scenes/[SUB-SCENES]/stage_select/stage_select.tscn")
var myfreindOptions = load("res://assets/scenes/[SUB-SCENES]/options_menu/options_menu.tscn")
var beautifulgallery = load("res://assets/scenes/[SUB-SCENES]/trophies_menu/trophies_menu.tscn")
var allThesePeople = load("res://assets/scenes/[SUB-SCENES]/credits_menu/credits_menu.tscn")

var buttonScales = [1.0,1.0,1.0,1.0]
var selectedButton = 0;

func _ready() -> void:
	updateButtonSelection()
	instantScale()

	for butt in buttons:
		butt.mouse_entered.connect(mouse_button.bind(butt))
		butt.pressed.connect(process_button.bind())

func instantScale():
	for i in range(buttons.size()):
		buttons[i].scale.x = buttonScales[i]
		buttons[i].scale.y = buttons[i].scale.x

func greyButtons():
	for i in range(buttons.size()):
		buttons[i].self_modulate = Color(0.4,0.4,0.4)
		buttonScales[i] = 0.9 if !SaveSystem.optionsData.get("video_reducedmotions", false) else 1.0;

func updateButtonSelection():
	greyButtons()
	buttons[selectedButton].self_modulate = Color(1.0,1.0,1.0)
	buttonScales[selectedButton] = 1.0
	
func _process(_delta: float) -> void:
	for i in range(buttons.size()):
		buttons[i].scale.x = lerp(buttons[i].scale.x, buttonScales[i], 0.3)
		buttons[i].scale.y = buttons[i].scale.x
		
	if scene.canInput:
		if Input.is_action_just_pressed("Up_UI"): 
			selectedButton = (selectedButton - 1) % 4
			if selectedButton < 0: selectedButton = 3
			updateButtonSelection()
			MenuSounds.playMenuSound('switch')
		elif Input.is_action_just_pressed("Down_UI"):
			selectedButton = (selectedButton + 1) % 4
			updateButtonSelection()
			MenuSounds.playMenuSound('switch')
		
		if Input.is_action_just_pressed("Accept_UI"):
			process_button()

func mouse_button(button):
	if scene.canInput:
		if selectedButton != button.get_meta("ID", 0): MenuSounds.playMenuSound('switch')
		
		selectedButton = button.get_meta("ID", 0)
		updateButtonSelection()

var subtitles = [
	"\"Adventure mode! You begin your adventure here!\"",
	"\"Trophies! Show off your hard work!\"",
	"\"Options! Select a feature you want to edit!\"",
	"\"Credits! Appreciate all the people here!\"",
]

func process_button():
	if scene.canInput:
		scene.canInput = false
		MenuSounds.playMenuSound('select')
		
		if selectedButton == 0:
			var instance = stageSel.instantiate()
			$Narration.stream = load("res://assets/sounds/voice/adventure_mode.ogg")
			$Narration.subtitle = subtitles[selectedButton]
			PlayGlobals.addSubstate(scene, instance);
		elif selectedButton == 1:
			var instance = beautifulgallery.instantiate()
			$Narration.stream = load("res://assets/sounds/voice/trophies.ogg")
			$Narration.subtitle = subtitles[selectedButton]
			PlayGlobals.addSubstate(scene, instance);
		elif selectedButton == 2:
			var instance = myfreindOptions.instantiate()
			$Narration.stream = load("res://assets/sounds/voice/options.ogg")
			$Narration.subtitle = subtitles[selectedButton]
			PlayGlobals.addSubstate(scene, instance);
		elif selectedButton == 3:
			var instance = allThesePeople.instantiate()
			$Narration.stream = load("res://assets/sounds/voice/credits.ogg")
			$Narration.subtitle = subtitles[selectedButton]
			PlayGlobals.addSubstate(scene, instance);
			
		await get_tree().create_timer(0.5, false).timeout
		if not scene.isTransitioning: $Narration.subtitle_play()

func wellithinkitstimetomoveonok():
	graveHand.play("Appear")
