extends Node3D

func _ready() -> void:
	if $Warning.stream != null: $Warning.subtitle_play()

	$View.modulate.a = 0.0;
	
	var twee = get_tree().create_tween()
	
	twee.tween_property($View, "modulate:a", 0.75, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	twee.tween_property($View, "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_delay(0.5)
	
	await twee.finished
	
	queue_free()
