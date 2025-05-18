extends CanvasLayer

var achievementTable = {
	"SetSail": {
		"ngID": null,
		"tier": 1,
		"name": "Setting Sail",
		"description": "Start the story on any difficulty."
	}
}

var acho = load("res://assets/scenes/[SUB-SCENES]/achievement/achievement.tscn").instantiate()
var curAcho
var achoY = 0

func _ready() -> void:
	layer = 126
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	checkAllAchievements()

func checkAllAchievements():
	for a in achievementTable.keys(): checkAchievement(a)

func checkAchievement(ach):
	if (ach == "SetSail"):
		if !PlayGlobals.areWeFNFFreeDownload and PlayGlobals.levelID == 'SHR':
			unlockAchievement(ach)

var achievementsToShow = []

func setPlacementY(num = null):
	achoY = num if num != null else 850

func _process(delta: float) -> void:
	if curAcho: curAcho.position.y = lerpf(curAcho.position.y, achoY, 0.5)

func unlockAchievement(ach):
	var hadChange = false;
	
	if SaveSystem.achievementData.gotten.find(ach) == -1:
		hadChange = true
		SaveSystem.achievementData.gotten.push_back(ach);
	
		var oldAch = achievementsToShow.duplicate()
		achievementsToShow.push_back(ach)
			
		if oldAch.size() == 0:
			showAchievementSequence()

	if hadChange: SaveSystem.saveSave()

func achievementPopup(ach):
	var shit = acho.duplicate()
	add_child(shit)
	
	curAcho = shit
	curAcho.position.y = achoY
	
	shit.achievement = achievementTable[ach]
	shit.start()
	shit.achievementShown.connect(showAchievementSequence.bind())

func showAchievementSequence():
	curAcho = null
	
	if achievementsToShow.size() != 0:
		achievementPopup(achievementsToShow[0])
		achievementsToShow.remove_at(0)
