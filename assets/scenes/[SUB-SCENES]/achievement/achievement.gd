extends Node2D

var achievement;
var a;
signal achievementShown;

func start():
	$Name.text = achievement.name
	
	for a in $Diffi.get_children().size():
		if int($Diffi.get_child(a).name) > achievement.tier: $Diffi.get_child(a).modulate = Color(0.0,0.0,0.0)
	
	position.x -= $ColorRect.size.x;
	
	MenuSounds.playMenuSound("achievement_tier"+str(achievement.tier))
	$Trophy.texture = load("res://assets/images/achievements/"+a+".png")
	
	get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(self, "position:x", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	
	await get_tree().create_timer(3.0).timeout
	
	var tro = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tro.tween_property(self, "position:x", -$ColorRect.size.x, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	await tro.finished
	
	achievementShown.emit()
	queue_free()
