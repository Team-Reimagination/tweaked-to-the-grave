extends TTTG_DistanceSpawner

func reset(isRecursive = false):
	super.reset(isRecursive)
	
	$AnimationPlayer.play("Rest")

func spawnLogic():
	if disabled: return
	
	spawned = true
	$Prep.subtitle_play()
	$AnimationPlayer.play("Start")
	
func imDone():
	pass

func imKillingMyself():
	if disabled: return
	
	$AnimationPlayer.stop()
	
	super.imKillingMyself()
