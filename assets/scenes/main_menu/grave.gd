extends Parallax2D

@onready var buttons = [$Buttons/Adventure, $Buttons/Trophies, $Buttons/Options]
@onready var graveHand = $Hand
@onready var scene = get_tree().current_scene

var stageSel = preload("res://assets/scenes/[SUB-SCENES]/stage_select/stage_select.tscn")

var buttonScales = [1.0,1.0,1.0]
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
		buttonScales[i] = 0.9;

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
			selectedButton = (selectedButton - 1) % 3
			if selectedButton < 0: selectedButton = 2
			updateButtonSelection()
			MenuSounds.playMenuSound('switch')
		elif Input.is_action_just_pressed("Down_UI"):
			selectedButton = (selectedButton + 1) % 3
			updateButtonSelection()
			MenuSounds.playMenuSound('switch')
		
		if Input.is_action_just_pressed("Accept_UI"):
			process_button()

func mouse_button(button):
	if scene.canInput:
		if selectedButton != button.get_meta("ID", 0): MenuSounds.playMenuSound('switch')
		
		selectedButton = button.get_meta("ID", 0)
		updateButtonSelection()

func process_button():
	if scene.canInput:
		scene.canInput = false
		MenuSounds.playMenuSound('select')
		
		if selectedButton == 0:
			var instance = stageSel.instantiate()
			PlayGlobals.addSubstate(scene, instance);
			
		await get_tree().create_timer(0.5).timeout
		$Buttons/Adventure/AdventureMode.play()
