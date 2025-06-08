extends TTTG_TimeSpawner

func spawnLogic():
	if disabled: return
	
	$Image.modulate.a = 0.0
	$Image.pixel_size *= 1.3
	
	$Prep.subtitle_play()
	
	var twe1 = get_tree().create_tween()
	twe1.tween_property($Image, "modulate:a", 1.0, spawnTime).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	twe1.set_parallel(true).tween_property($Image, "pixel_size", $Image.pixel_size / 1.3, spawnTime).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	await twe1.finished
	
	spawnBullets()

func _process(delta: float) -> void:
	if disabled: return
	
	super._process(delta)
	
	if spawned and !$Launch.playing:
		queue_free()

func imDone():
	if disabled: return
	
	var twe1 = get_tree().create_tween()
	twe1.tween_property($Image, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	twe1.set_parallel(true).tween_property($Image, "pixel_size", $Image.pixel_size * 1.3, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
