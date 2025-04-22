extends Control

@onready var portrait = $Portrait
@onready var box = $Box
@onready var dialName = $Name
@onready var dialText = $Text
@onready var dialVoice = $Audio/Voice
@onready var timeout = $Timeout

var typing = false
var movingOn = true
var pressedToSkip = false

var dialogue = {}
const PATH_DIALOGUE = "res://assets/data/dialogue/"

var charAliases = {
	"bob": "bob tweaked",
	"tweak": "the tweak",
	"tweak_final": "the tweak",
	"eyad_irl": "eyad",
	"freindly": "freindly fellow",
	"seezee": "seezee553"
}

var dialEventNum = 0;
var oldDialEvent = {}
var dialEvent = {}

var dialTime = 0.4
var dialAccess = "keys"

func _ready() -> void:
	portrait.scale.y = 0.0;
	box.scale.y = 0.0;
	dialName.visible = false
	dialText.visible = false
	
	#startDialogue("freindly")

func startDialogue(path):
	if FileAccess.file_exists(PATH_DIALOGUE+path+'.json'):
		dialogue = JSON.parse_string(FileAccess.open(PATH_DIALOGUE+path+'.json', FileAccess.READ).get_as_text())
		
		beginning()
	else :
		print("Could Not Find DIALOGUE For "+path+'!')

func beginning():
	portrait.play("inter")
	
	var comTween = get_tree().create_tween()
	comTween.tween_property(portrait, "scale:y", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	comTween.set_parallel(true).tween_property(box, "scale:y", 0.93, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	$Audio/TransIn.play()
	
	await $Audio/TransIn.finished
	checkDialogue()

func ending():
	portrait.play("inter")
	
	dialName.visible = false
	dialText.visible = false
	
	var comTween = get_tree().create_tween()
	comTween.tween_property(portrait, "scale:y", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	comTween.set_parallel(true).tween_property(box, "scale:y", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	$Audio/TransOut.play()
	
	await $Audio/TransOut.finished
	exitThisWay()

func exitThisWay():
	queue_free()

func proceedWithDialogue():
	dialEvent = dialogue.events[dialEventNum]
	
	if oldDialEvent == {} or dialEvent.char == oldDialEvent.char: typeIt()
	else:
		$Audio/Static.play()
		portrait.play("inter")
		
		dialName.visible = false
		dialText.visible = false
		
		await $Audio/Static.finished
		typeIt()

func typeIt():
	movingOn = false
	
	dialName.visible = true
	dialText.visible = true
	
	dialName.text = dialEvent.char if !charAliases.has(dialEvent.char) else charAliases[dialEvent.char]
	portrait.play(dialEvent.char)
	
	dialText.text = dialEvent.text
	dialText.visible_characters = 0;
	typing = true
	
	dialTime = dialEvent.textTime if dialEvent.has("textTime") else 0.04
	dialAccess = dialEvent.nextAccess if dialEvent.has("nextAccess") else "keys"
	
	if dialEvent.has("voice"):
		dialVoice.stream = load("res://assets/sounds/voice/dialogue/"+dialEvent.voice+".ogg")
		dialVoice.play()
		if dialAccess != "keys" and dialAccess != "none": processVoice()
	
	for character in range(len(dialText.text)):
		if !typing: break
		dialText.visible_characters += 1;
		await get_tree().create_timer(dialTime).timeout
	
	if !dialEvent.has("voice") and dialAccess != "keys" and dialAccess != "none": wait()
	
	portrait.stop()
	portrait.frame = 0
	typing = false

func processVoice():
	await dialVoice.finished
	if !movingOn: wait()

func wait():
	timeoutInitialized = true
	timeout.start(1.0)

func nextDialogue():
	dialEventNum += 1
	oldDialEvent = dialEvent
	dialEvent = {}
	
	checkDialogue()

func checkDialogue():
	movingOn = true
	
	if dialogue.events.size()-1 < dialEventNum:
		ending()
	else:
		proceedWithDialogue()

var timeoutTimer = Timer.new()
var timeoutInitialized = false

func _process(_delta: float) -> void:
	if timeoutInitialized and timeout.time_left <= 0 and !movingOn and !pressedToSkip: 
		timeoutInitialized = false
		pressedToSkip = false
		nextDialogue()

	if dialAccess != "timeout" and dialAccess != "none":
		if Input.is_action_just_pressed("Accept_UI"):
			if typing: skipText()
			else: moveOn()

func skipText():
	typing = false;
	dialText.visible_characters = -10;
	timeout.stop()
	timeoutInitialized = false
	pressedToSkip = true
	
func moveOn():
	if !movingOn:
		timeout.stop()
		timeoutInitialized = false
		pressedToSkip = false
		if dialVoice.playing: dialVoice.stop()
		nextDialogue()
