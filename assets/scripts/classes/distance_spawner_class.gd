class_name TTTG_DistanceSpawner
extends TTTG_Obstacle

@export var distanceToSpawn = 500.0

var spawned = false

func _ready() -> void:
	if disabled: return
	super._ready()
	
	$Explosion.visible = false
	
func _process(delta: float) -> void:
	if disabled: return
	super._process(delta)
	
	if self.global_position.z > -distanceToSpawn and !spawned:
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

func imKillingMyself():
	if disabled: return
	isGhost = true
	isDying = true
	
	if $Prep.stream != null: $Prep.stop()
	$Explosion.visible = true
	$Explosion.play("default")
	
	if !scene.hasBitchWon: $Explode.subtitle_play()
	
	$Model.visible = false
	
	await $Explosion.animation_finished
	queue_free()

func victory_screech():
	if disabled: return
	queue_free()
