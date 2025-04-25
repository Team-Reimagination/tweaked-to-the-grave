extends TextureButton

var level = 'SHR'

func create(lv = 'SHR'):
	level = lv
	set_meta("level",level)
	
	$Frame/Background.texture = load("res://assets/images/levels/"+level+"/levelbg.png")
	$Frame/Title.texture = load("res://assets/images/levels/"+level+"/tinytitle.png")
	
	var locked = SaveSystem.hasNotUnlockedLevel(level)
	set_meta("locked",locked)
	
	$Lock.visible = locked
	$Frame.modulate = Color(0.7,0.7,0.7) if locked else Color(1.0,1.0,1.0)
	
	$Frame/Score.visible = !locked
	
func applyScore(diff):
	$Frame/Score.text = str(SaveSystem.getHighScore(level, diff))
