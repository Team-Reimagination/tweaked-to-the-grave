extends CanvasLayer

var achievementTable = {
	"SetSail": {
		"ngID": null,
		"tier": 1,
		"name": "Setting Sail",
		"desc": "Start the story on any difficulty."
	},
	"MakeNoMistake": {
		"ngID": null,
		"tier": 2,
		"name": "Make No Mistake",
		"desc": "Beat a level without taking any damage."
	}
}

var acho = load("res://assets/scenes/[SUB-SCENES]/achievement/achievement.tscn").instantiate()
var curAcho
var achoY = 0

func _ready() -> void:
	layer = 126
	process_mode = Node.PROCESS_MODE_ALWAYS

var achievementsToShow = []

func setPlacementY(num = null):
	achoY = num if num != null else 0.0

func _process(delta: float) -> void:
	if curAcho: curAcho.position.y = lerpf(curAcho.position.y, achoY, 0.5)

func unlockAchievement(ach):
	var hadChange = false;
	
	if SaveSystem.achievementData.gotten.find(ach) == -1:
		hadChange = true
		SaveSystem.achievementData.gotten.push_back(ach);
	
		var oldAch = achievementsToShow.duplicate()
		achievementsToShow.push_back(ach)
		
		print(achievementsToShow)
		print(oldAch)
		if oldAch.size() == 0:
			achievementPopup(achievementsToShow[0])

	if hadChange: SaveSystem.saveSave()

func achievementPopup(ach):
	var shit = acho.duplicate()
	add_child(shit)
	
	curAcho = shit
	curAcho.position.y = achoY
	
	shit.achievement = achievementTable[ach]
	shit.a = ach
	shit.start()
	shit.achievementShown.connect(showAchievementSequence.bind())

func showAchievementSequence():
	achievementsToShow.remove_at(0)
	curAcho = null
	
	if achievementsToShow.size() != 0:
		achievementPopup(achievementsToShow[0])

func hasItUnlocked(ach):
	return SaveSystem.achievementData.gotten.find(ach) != -1
