class_name TTTG_Collectible_Holder
extends TTTG_Obstacle

func _ready() -> void:
	super._ready()
	
	$Explosion.visible = false
	
func reset(isRecursive = false):
	super.reset(isRecursive)
	
	$Explosion.visible = false
	$Model.visible = true
	disabled = false
	
func spawnCollectible():
	if disabled: return
	for a in $Spawn.get_children():
		var b = a.duplicate()
		
		b.disabled = false
		scene.spawnOBJ(b)
		
		b.global_position = a.global_position
		
		if b is TTTG_Collectible:
			b.startSucking = true
			b.get_node("./Attraction").subtitle_play()

func imKillingMyself():
	if disabled: return
	isGhost = true
	isDying = true
	
	$Explosion.visible = true
	$Explosion.play("default")
	
	if !scene.hasBitchWon: 
		$Explode.subtitle_play()
		spawnCollectible()
	
	$Model.visible = false
	
	disabled = true
	await $Explosion.animation_finished

func victory_screech():
	queue_free()
