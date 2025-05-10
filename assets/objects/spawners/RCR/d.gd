extends "res://assets/scripts/classes/object_specific/hieroglyph_spawner.gd"

func spawnBullets():
	if disabled: return
	
	get_tree().create_tween().tween_property(self, "global_position:x", global_position.x - 40, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	for a in 5:
		if a != 0 and a != 4:
			var b = $Spawn.get_child(0).duplicate()
			
			$Launch.subtitle_play()
			
			b.disabled = false
			scene.spawnOBJ(b)
			
			b.global_position = $Spawn.get_child(0).global_position
		
		await get_tree().create_timer(2.0/5.0, false).timeout
	
	spawned = true
	imDone()
