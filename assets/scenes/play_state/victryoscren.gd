extends CanvasLayer

var looper = 0

@onready var buttons = [$Buttons/Proceed, $"Buttons/New Tries", $Buttons/Return]
var buttonScales = [0.0,0.0,0.0]
var selectedButton = 0

var canInput = false

func _ready() -> void:
	if PlayGlobals.areWeFNFFreeDownload:
		buttons[0].queue_free()
		buttons = [$"Buttons/New Tries", $Buttons/Return]
		
	for a in range(buttons.size()):
		buttons[a].set_meta("ID", a)
		
		if !PlayGlobals.areWeFNFFreeDownload: buttons[a].position.x = 50.0 + 1080.0 / buttons.size() * a
		else: buttons[a].position.x = 230.0 + 750.0 / buttons.size() * a
	
	updateButtonSelection()
	instantScale()
	
	$Higher.scale *= 0.0

	for butt in buttons:
		butt.mouse_entered.connect(mouse_button.bind(butt))
		butt.pressed.connect(process_button.bind())
		
	$Unlocked.scale *= 0.0

func instantScale():
	for i in range(buttons.size()):
		buttons[i].scale.x = buttonScales[i]
		buttons[i].scale.y = buttons[i].scale.x

func greyButtons():
	for i in range(buttons.size()):
		buttons[i].self_modulate = Color(0.4,0.4,0.4)
		if canInput: buttonScales[i] = 0.8 * 0.9;

func updateScale():
	buttonScales[selectedButton] = 0.8

func updateButtonSelection():
	greyButtons()
	buttons[selectedButton].self_modulate = Color(1.0,1.0,1.0)

func start():
	Subtitles.setPlacementY(750)
	Subtitles.setPlacementX(null)
	
	await get_tree().create_timer(2.0).timeout
	
	$TitleCard.texture = load("res://assets/images/levels/"+PlayGlobals.levelID+"/titlecard.png")
	
	for a in [$Seezee, $Has, $Passed, $TitleCard]:
		a.descend(0.25,40.0 + 5.0 * looper,0.3)
		await a.is_done_exploding
		looper += 1;
	
	if get_parent().unlockedLevel:
		MenuSounds.playMenuSound("small_select")
		get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_BOUND).tween_property($Unlocked, "scale", Vector2(1.0,1.0),0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	if get_parent().newHighScore:
		$"../Audio/Highscore".subtitle_play()
		
		var scaler = get_tree().create_tween()
		scaler.tween_property($Higher, "scale", Vector2(0.75,0.75), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		
		await scaler.finished
		SometimesIWishThisOneSeriesWasToBePopularizedAcrossTheGlobe_ItsCalledPrzygodyReksia_ItsAPolishFranchiseButItIsGreat_IfOnlyThisHadEnglishLocalization_ButIKnowAYoutubeChannelThatOffersSubtitlesToGames_GoCheckKretKretesRecordsToSeeThat()
	else:
		SometimesIWishThisOneSeriesWasToBePopularizedAcrossTheGlobe_ItsCalledPrzygodyReksia_ItsAPolishFranchiseButItIsGreat_IfOnlyThisHadEnglishLocalization_ButIKnowAYoutubeChannelThatOffersSubtitlesToGames_GoCheckKretKretesRecordsToSeeThat()

func SometimesIWishThisOneSeriesWasToBePopularizedAcrossTheGlobe_ItsCalledPrzygodyReksia_ItsAPolishFranchiseButItIsGreat_IfOnlyThisHadEnglishLocalization_ButIKnowAYoutubeChannelThatOffersSubtitlesToGames_GoCheckKretKretesRecordsToSeeThat():
	canInput = true
	updateButtonSelection()
	updateScale()

func _process(_delta: float) -> void:
	if get_parent().hasBitchWon:
		for i in range(buttons.size()):
			buttons[i].scale.x = lerp(buttons[i].scale.x, buttonScales[i], 0.3)
			buttons[i].scale.y = buttons[i].scale.x
				
		if canInput:
			if Input.is_action_just_pressed("Left_UI"): 
				selectedButton = (selectedButton - 1) % buttons.size()
				if selectedButton < 0: selectedButton = buttons.size()-1
				updateButtonSelection()
				updateScale()
				MenuSounds.playMenuSound('switch')
			elif Input.is_action_just_pressed("Right_UI"):
				selectedButton = (selectedButton + 1) % buttons.size()
				updateButtonSelection()
				updateScale()
				MenuSounds.playMenuSound('switch')
			
			if Input.is_action_just_pressed("Accept_UI"):
				process_button()

func mouse_button(button):
	if canInput:
		if selectedButton != button.get_meta("ID", 0): MenuSounds.playMenuSound('switch')
		
		selectedButton = button.get_meta("ID", 0)
		updateButtonSelection()
		updateScale()

func process_button():
	if canInput:
		PlayGlobals.youarenolongermyfriendsoundnowgoaway((selectedButton != 0 and !PlayGlobals.areWeFNFFreeDownload) or PlayGlobals.areWeFNFFreeDownload)
		MenuSounds.playMenuSound('select')
		
		if !PlayGlobals.areWeFNFFreeDownload and selectedButton != 1:
			get_parent().setCurrentSave()
		
		canInput = false
		if (selectedButton != 0 and !PlayGlobals.areWeFNFFreeDownload) or PlayGlobals.areWeFNFFreeDownload:
			TransFuncs.switchScenes(get_parent(), "reset" if buttons[selectedButton] != $Buttons/Return else "res://assets/scenes/main_menu/main_menu.tscn")
		else:
			get_parent().nextLevel()
			
			get_tree().create_tween().tween_property($Color, "color:a", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			get_tree().create_tween().tween_property(self, "scale", Vector2(2,2), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			get_tree().create_tween().tween_property(self, "offset", Vector2(-640.0,-480.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			
			$"../Audio/Hyperdrive".subtitle_play()
			get_parent().shaders.wybielenie(0.5)
			get_tree().create_tween().tween_property(get_parent().player, "position:z", -500, 3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			get_parent().camera.shake(5.0,2.0);
			get_tree().create_tween().tween_property($"../Audio/Victory", "pitch_scale", 0.001, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			
			await get_tree().create_timer(0.75).timeout
			TransFuncs.switchScenes(get_parent(), "reset")
