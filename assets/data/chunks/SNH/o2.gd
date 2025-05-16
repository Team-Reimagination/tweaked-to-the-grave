extends TTTG_TimeSpawner

var possy = []

func spawnBullets():
	$Launch.subtitle_play()
	
	for b in $Spawn.get_children():
		possy.push_back(b.global_position)
	
	if disabled: return
	for a in 10:
		for b in $Spawn.get_children().size():
			var c = $Spawn.get_child(b).duplicate()
			
			c.disabled = false
			scene.spawnOBJ(c)
			
			c.global_position = possy[b].global_position
		
		await get_tree().create_timer(0.4, false).timeout
		print(a)
	
	spawned = true
	imDone()
