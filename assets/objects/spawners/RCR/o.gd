extends "res://assets/scripts/classes/object_specific/hieroglyph_spawner.gd"

func spawnBullets():
	if disabled: return
	
	var twe = get_tree().create_tween().tween_property(self, "global_position:y", global_position.y + 3, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	await twe.finished
	
	twe = get_tree().create_tween().tween_property(self, "global_position:y", scene.btmF.global_position.y+5 if scene.btmF.global_position.y > -10 else -10, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	
	await twe.finished
	
	$Launch.subtitle_play()
	
	for a in 5:
		var b = $Spawn.get_child(0).duplicate()
			
		b.disabled = false
		b.speed = randf_range(20,35)
		b.get_child(8).position.x = randf_range(-10, 10)
		scene.spawnOBJ(b)
			
		b.global_position = $Spawn.get_child(0).global_position
	
	spawned = true
	imDone()
