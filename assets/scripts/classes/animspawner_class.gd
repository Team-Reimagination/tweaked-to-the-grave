class_name TTTG_AnimatedSpawner
extends TTTG_Obstacle

var spawned = false

func reset(isRecursive = false):
	super.reset(isRecursive)
	
	spawned = false

func _ready() -> void:
	super._ready()
	spawnLogic()
	
func spawnLogic():
	if disabled: return
	spawnBullets()
	
func spawnBullets():
	$Launch.subtitle_play()
	
	if disabled: return
	for a in $Spawn.get_children():
		var b = a.duplicate()
		
		b.disabled = false
		scene.spawnOBJ(b)
		
		b.global_position = a.global_position
	
	spawned = true
	imDone()
	
func imDone():
	if disabled: return
	imKillingMyself()

func victory_screech():
	queue_free()
