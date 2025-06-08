extends TTTG_AnimatedSpawner

func _ready() -> void:
	super._ready()
	
	$Model.visible = false;
	$Explosion.visible = false;
	
func spawnLogic():
	if disabled: return
	
	$Model.visible = true;
	$Model/Sprite.play("Appear")
	$Laugh.subtitle_play()
	
	await get_tree().create_timer(1.5).timeout
	
	$Model/Sprite.play("Explode")
	$Scream.subtitle_play()
	
	await $Model/Sprite.animation_finished
	
	$Scream.stop()
	$Model.visible = false;
	spawnBullets()
	
func spawnBullets():
	$Launch.subtitle_play()
	$Explosion.visible = true
	$Explosion.play()
	
	disabled = true
	
	var bullet = $Spawn.get_child(0)

	for a in 50:
		var b = bullet.duplicate()
		
		b.disabled = false
		
		b.get_node("./Direction").position.x = sin(a/1.4)
		b.get_node("./Direction").position.y = cos(a/1.4)
		scene.spawnOBJ(b)
		
		b.global_position = bullet.global_position
		
		await get_tree().create_timer(0.03, false).timeout
	
func imDone():
	pass

func victory_screech():
	queue_free()
