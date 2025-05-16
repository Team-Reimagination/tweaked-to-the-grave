extends TTTG_TimeSpawner

func spawnBullets():
	$Launch.subtitle_play()
	
	if disabled: return
	for a in 15:
		var b = $Spawn.get_child(0).duplicate()
		
		b.disabled = false
		b.get_node("./Direction").position.x += randf_range(-2.0, 2.0);
		b.speed += randf_range(-5.0, 10.0);
		scene.spawnOBJ(b)
		
		b.global_position = $Spawn.get_child(0).global_position
	
	spawned = true
	imDone()
