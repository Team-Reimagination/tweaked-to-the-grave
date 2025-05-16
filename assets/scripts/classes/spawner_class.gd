class_name TTTG_TimeSpawner
extends TTTG_Obstacle

var spawned = false
@export var spawnTime = 1.0

func _ready() -> void:
	super._ready()
	
	spawnLogic()
	
func spawnLogic():
	if disabled: return
	
	await get_tree().create_timer(spawnTime, false).timeout
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
	if disabled: return
	queue_free()
