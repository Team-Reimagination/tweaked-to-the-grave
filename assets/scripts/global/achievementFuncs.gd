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
	},
	"FullPower": {
		"ngID": null,
		"tier": 3,
		"name": "Full Of Powers",
		"desc": "Reach the maximum weapon level on any difficulty that lets you level up."
	},
	"CompleteGame1": {
		"ngID": null,
		"tier": 3,
		"name": "The One-Off Hero",
		"desc": "Finish the story on the \"Terios Mode\" difficulty."
	},
	"CompleteGame2": {
		"ngID": null,
		"tier": 3,
		"name": "The Local Hero",
		"desc": "Finish the story on the \"Cn Y Give Me Life\" difficulty."
	},
	"CompleteGame3": {
		"ngID": null,
		"tier": 4,
		"name": "The Great Hero",
		"desc": "Finish the story on the \"A Meaty Surprise\" difficulty."
	},
	"CompleteGame4": {
		"ngID": null,
		"tier": 4,
		"name": "The Valiant Hero",
		"desc": "Finish the story on the \"Bloodshed\" difficulty."
	},
	"CompleteGame5": {
		"ngID": null,
		"tier": 5,
		"name": "The Unstoppable Hero",
		"desc": "Finish the story on the \"Ultimate Heatstruction\" difficulty."
	},
	"AllAchievements": {
		"ngID": null,
		"tier": 5,
		"name": "Truly Six Feet Under",
		"desc": "Get all achievements."
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
		
		if oldAch.size() == 0:
			achievementPopup(achievementsToShow[0])

	if hadChange: SaveSystem.saveSave()
	
	if SaveSystem.achievementData.gotten.size() == achievementTable.keys().size() - 1: unlockAchievement("AllAchievements")

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
