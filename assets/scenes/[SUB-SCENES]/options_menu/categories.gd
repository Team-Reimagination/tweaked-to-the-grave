extends CanvasLayer

@onready var substate = $".."

var categories = ["video", "audio", "gameplay", "misc"]
var categoryLabels = []
var categoryScales = []

static var curCategory = 0
static var curSelected = 1
var mouseBtn = -1

@onready var catButtons = [$CategoryButtons/Left, $CategoryButtons/Right]
var catButtonScales = [1.0,1.0]

@onready var catToCat= {
	"video": $Options/video,
	"audio": $Options/audio,
	"gameplay": $Options/gameplay,
	"controls": $Options/controls,
	"misc": $Options/misc,
}

@onready var boxer = $OptionColor
var boxPositions = Vector2(0.0,0.0)
var boxSizes = Vector2(0.0,0.0)
var boxAlpha = 0.0

func _ready() -> void:
	for cat in categories.size():
		var label = Sprite2D.new()
		label.texture = load("res://assets/images/menu/options/label-"+categories[cat]+".png")
		
		$Categories/Group.add_child(label)
		label.global_position = $Categories.global_position + $Categories.pivot_offset
		label.global_position.x += 300 * cat
		label.scale *= 1.5 if cat == curCategory else 1.0
		
		categoryLabels.push_back(label)
		categoryScales.push_back(label.scale.x)
	
	for a : String in SaveSystem._defaultOptionsData.keys():
		if SaveSystem.optionDefines[a].get("pc", false) and OS.has_feature("web"): continue
		
		var opti = load("res://assets/scenes/[SUB-SCENES]/options_menu/options_option/option.tscn").instantiate()
		
		var categoro : Node2D = catToCat.get(a.split("_")[0])
		
		opti.optionToLookInto = a
		
		addOption(opti, categoro)
	
	for ass in 4:
		var opti = load("res://assets/scenes/[SUB-SCENES]/options_menu/options_option/option_button.tscn").instantiate()
		
		var categoro : Node2D = $Options/misc
		
		addOption(opti, categoro)
	
	moveCategoryRow(false)

	for a : TextureButton in catButtons:
		a.mouse_entered.connect(catMouseHover.bind(a))
		a.pressed.connect(catMousePress.bind())
	
	for a in $Options.get_children().size():
		if a != curCategory: $Options.get_child(a).position.x = 2 << 10
	
	optionMovement(0)
	boxerMove()
	instantBoxMove()

func addOption(child, cat):
	child.substate = substate
	child.selection = cat.get_children().size()+1
	child.category = $Options.get_children().find(cat)
		
	cat.add_child(child)
	child.position.x += child.get_node("./Size").size.x / 2.0
	child.position.y += child.get_node("./Size").size.y / 2.0 + (child.get_node("./Size").size.y + 10) * (cat.get_children().size() - 1) + 20

func boxerMove():
	var whatToUse = ($Options.get_child(curCategory).get_child(0) if $Options.get_child(curCategory).get_children().size() > 0 else $Categories/Group.get_child(curCategory)) if curSelected == 0 else $Options.get_child(curCategory).get_child(curSelected-1)
	
	boxSizes = whatToUse.get_node("./Rectangle").size if whatToUse is not Sprite2D else whatToUse.texture.get_size()
	boxPositions = whatToUse.global_position
	
	boxer.self_modulate.a = lerpf(boxer.self_modulate.a, boxAlpha, 0.7 if whatToUse is Sprite2D else 0.2)
	boxer.position.x = boxPositions.x - (boxer.size.x/2.0)
	boxer.position.y = lerpf(boxer.position.y, boxPositions.y - (boxer.size.y/2.0), 0.3)
	boxer.size.x = lerpf(boxer.size.x, boxSizes.x, 0.3)
	boxer.size.y = lerpf(boxer.size.y, boxSizes.y, 0.3)

func instantBoxMove():
		boxer.size = boxSizes
		boxer.position = boxPositions
		boxer.self_modulate.a = boxAlpha

func catMouseHover(button):
	if substate.process_mode != Node.PROCESS_MODE_DISABLED and substate.canInput:
		if mouseBtn < 0 or mouseBtn != button.get_meta("ID", 0): MenuSounds.playMenuSound('switch')
		
		mouseBtn = button.get_meta("ID", 0)
		
		updateCatButtonSelection()

func updateCatButtonSelection():
	for a in catButtons.size():
		catButtons[a].modulate = Color(0.6,0.6,0.6) if mouseBtn != -1 else Color(1.0,1.0,1.0)
		catButtonScales[a] = 0.9 if mouseBtn != -1 and !SaveSystem.optionsData.get("video_reducedmotions", false) else 1.0
	
	if mouseBtn != -1:
		catButtonScales[mouseBtn] = 1.0
		catButtons[mouseBtn].modulate = Color(1.0,1.0,1.0)

func catMousePress():
	if substate.canInput:
		if mouseBtn >= -1: MenuSounds.playMenuSound('small_select')
		
		catMovement(-1 if mouseBtn == 0 else 1)

func moveCategoryRow(doLerp):
	var positionToLookFor = -categoryLabels[curCategory].position.x + $Categories.size.x/2
	$Categories/Group.position.x = lerp($Categories/Group.position.x, positionToLookFor, 0.2) if doLerp else positionToLookFor

func _process(delta: float) -> void:
	boxerMove()
	
	for i in catButtons.size():
		catButtons[i].scale.y = lerpf(catButtons[i].scale.y, catButtonScales[i], 0.3)
		catButtons[i].scale.x = catButtons[i].scale.y
		
	for i in categoryLabels.size():
		categoryLabels[i].scale.y = lerpf(categoryLabels[i].scale.y, categoryScales[i], 0.3 if !SaveSystem.optionsData.get("video_reducedmotions", false) else 1.0)
		categoryLabels[i].scale.x = categoryLabels[i].scale.y
		
	moveCategoryRow(true)
	
	if substate.canInput:
		if (Input.is_action_just_pressed("Left_GP") and curSelected == 0) or Input.is_action_just_pressed("LShoulder_UI"):
			catSwitch(-1)
		elif (Input.is_action_just_pressed("Right_GP") and curSelected == 0) or Input.is_action_just_pressed("RShoulder_UI"):
			catSwitch(1)
		elif Input.is_action_just_pressed("Up_GP"):
			mouseBtn = -1
			updateCatButtonSelection()
			
			optionMovement(-1)
			
			MenuSounds.playMenuSound("switch")
		elif Input.is_action_just_pressed("Down_GP"):
			mouseBtn = -1
			updateCatButtonSelection()
			
			optionMovement(1)
			
			MenuSounds.playMenuSound("switch")

var catMovements

func catSwitch(dir):
	mouseBtn = -1
	catMovement(dir)
	updateCatButtonSelection()
			
	MenuSounds.playMenuSound("small_select")

func catMovement(dir):
	var oldCat = $Options.get_child(curCategory)
	
	curCategory += dir
	if curCategory < 0: curCategory = categories.size()-1
	elif curCategory >= categories.size(): curCategory = 0
	
	var newCat = $Options.get_child(curCategory)
	
	if curSelected > $Options.get_child(curCategory).get_children().size():
		curSelected = $Options.get_child(curCategory).get_children().size()
		if curSelected == 0: boxAlpha = 0.0
	
	if !SaveSystem.optionsData.get("video_reducedmotions", false): catButtons[0 if dir == -1 else 1].scale *= 0.7
	
	for a in $Options.get_children():
		if a != oldCat and a != newCat:
			a.position.x = 2 << 10
			a.modulate.a = 0.0
	
	for a in categoryScales.size():
		categoryScales[a] = 1.5 if a == curCategory else 1.0
		
	if catMovements: catMovements.kill()
	
	catMovements = get_tree().create_tween()
	catMovements.tween_property(oldCat, "modulate:a", 0.0, 0.125).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	if !SaveSystem.optionsData.get("video_reducedmotions", false): catMovements.set_parallel(true).tween_property(oldCat, "position:x", oldCat.position.x - 50 * dir, 0.125).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	
	await catMovements.finished
	
	oldCat.position.x = 2 << 10
	newCat.position.x = 50 * dir if !SaveSystem.optionsData.get("video_reducedmotions", false) else 0.0
	newCat.modulate.a = 0.0
	
	catMovements = get_tree().create_tween()
	catMovements.tween_property(newCat, "modulate:a", 1.0, 0.125).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	if !SaveSystem.optionsData.get("video_reducedmotions", false): catMovements.set_parallel(true).tween_property(newCat, "position:x", 0.0, 0.125).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)

func optionMovement(dir):
	curSelected += dir
	if curSelected < 0: curSelected = $Options.get_child(curCategory).get_children().size()
	elif curSelected > $Options.get_child(curCategory).get_children().size(): curSelected = 0
	
	boxAlpha = min(curSelected, 1)
