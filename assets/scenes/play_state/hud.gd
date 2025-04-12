extends CanvasLayer

@onready var scene = self.get_parent();
@onready var liraGroup = $LiraGroup
@onready var powerText = $LiraGroup/Lira
@onready var liraBar = $LiraGroup/LiraBar
@onready var hurt = $Hurt
@onready var explosion = $Explosion
@onready var seezeeIcon = $HealthGroup/IconSeezee
@onready var bossIcon = $HealthGroup/IconTweak

var lira:int = 0;
var liraShakeTween;
var lifeShakeTween;

func postLevelBuild():
	bossIcon.sprite_frames = load("res://assets/images/hud/icons/"+scene.bossDEF.type+".tres")
	bossIcon.play("Idle")
	
	powerText.text = str(lira)
	
	#LIVE TEXT SETUP
	$HealthGroup/IconSeezee/Lives/Label.text = str(scene.lives)
	$HealthGroup/IconTweak/Lives/Label.text = str(int(8 - scene.levelNum))
	
	#choose health icon
	seezeeIcon.play("Heat_"+str(scene.player_health))
	
	#value healthing
	#$HealthGroup/HealthTweak/HealthBar.max_value = scene.boss_health
	#$HealthGroup/HealthTweak/HealthBar.value = scene.cur_boss_health
	
	for i in $HealthGroup/HealthSeezee/HealthSteps.get_children(true):
		if int(i.name) > scene.player_health: i.visible = false
	
	#lira, only visible if you're not willing to go kill yourself
	$LiraGroup/LiraBar.visible = PlayGlobals.maxLiraLevel > 1
	$LiraGroup/LevelText.visible = PlayGlobals.maxLiraLevel > 1
	
func _on_tree_entered() -> void: #some preparation because you never know
	liraGroup.material.set("shader_parameter/multipliers", [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0])
	
func levelUpLira():
	#if at max level, make it look like there is no more room
	if scene.liraLevel < PlayGlobals.maxLiraLevel:
		liraBar.max_value = scene.liraMax
	else:
		liraBar.max_value = 0
	
	#one more particleshot
	$LiraGroup/LiraParticles.restart()
	#set level
	$LiraGroup/LevelText.text = "LV "+str(scene.liraLevel)
	
	if scene.liraLevel > 1:
		#of course do that because by default it is invisible
		$LiraGroup/LiraParticles.self_modulate = Color(1.0,1.0,1.0,1.0)
		$LiraGroup/LevelUp.play()
		
		liraGroup.position.y = 50.0;
		if liraShakeTween:
			liraShakeTween.kill()
		liraShakeTween = get_tree().create_tween()
		liraShakeTween.tween_property(liraGroup, "position:y", 0, 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
		liraGroup.material.set("shader_parameter/offsets", Vector4(1.0, 1.0, 1.0, 0.0))
		liraShakeTween.set_parallel().tween_property(liraGroup.material, "shader_parameter/offsets", Vector4(0.0, 0.0, 0.0, 0.0), 0.2).set_trans(Tween.TRANS_QUART)

func healthLoss(): #go away you got a minor heatstroke
	var heal = $HealthGroup/HealthSeezee/HealthSteps.get_child(3 - (scene.player_health+1))
	
	var healer1 = get_tree().create_tween()
	healer1.tween_property(heal, "scale", Vector2(1.3,1.3), 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	healer1.set_parallel().tween_property(heal, "modulate", Color(1.0,1.0,1.0,0.0), 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func updateIcon():
	seezeeIcon.play("Heat_"+str(scene.player_health))

func hurtPlayer(): #minor heatstroke
	healthLoss()
	
	seezeeIcon.play("Hurt")
	
	hurt.visible = true
	hurt.rotation = randf()
	hurt.scale.x = randf_range(2.5,3.5)
	hurt.scale.y = hurt.scale.x
	hurt.position = $"../Camera".unproject_position(scene.player.position) #3d space into 3d screen
	await get_tree().create_timer(0.1, false).timeout
	hurt.visible = false
	
func loseLife():
	healthLoss()
	
	var canyougivemelife = $HealthGroup/IconSeezee/Lives
	canyougivemelife.position.y = 20.0;
	if lifeShakeTween:
		lifeShakeTween.kill()
	lifeShakeTween = get_tree().create_tween()
	lifeShakeTween.tween_property(canyougivemelife, "position:y", 0, 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
	canyougivemelife.material.set("shader_parameter/multipliers", [1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0])
	lifeShakeTween.set_parallel().tween_property(canyougivemelife.material, "shader_parameter/multipliers", [1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0], 0.2).set_trans(Tween.TRANS_QUART)
	
	canyougivemelife.material.set("shader_parameter/offsets", Vector4(1.0, 0.0, 0.0, 0.0))
	lifeShakeTween.set_parallel().tween_property(canyougivemelife.material, "shader_parameter/offsets", Vector4(0.0, 0.0, 0.0, 0.0), 0.2).set_trans(Tween.TRANS_QUART)
	
	$HealthGroup/IconSeezee/Lives/Label.text = str(scene.lives)
	
	#random chance
	seezeeIcon.play("Death" if randf() > 0.1 else "Death_Alt")
	
	explosion.visible = true
	explosion.position = $"../Camera".unproject_position(scene.player.position)
	explosion.play("default")
	
	#DOWNGRADE YOUR POWERS, THE FUCKING PUNISHMENT FOR BEING BAD /j
	if scene.liraLevel > 1:
		scene.liraPGR = 0
		scene.liraLevel = max(1, scene.liraLevel - 3)
		
		scene.liraMax = scene.levelUpLiraFormula(scene.liraLevel)
		liraBar.max_value = scene.liraMax
		
		$LiraGroup/LevelText.text = "LV "+str(scene.liraLevel)
		
		$LiraGroup/MoneyLoss.play()
		
		liraGroup.position.y = 50.0;
		if liraShakeTween:
			liraShakeTween.kill()
		liraShakeTween = get_tree().create_tween()
		liraShakeTween.tween_property(liraGroup, "position:y", 0, 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
		liraGroup.material.set("shader_parameter/offsets", Vector4(1.0, -1.0, -1.0, 0.0))
		lifeShakeTween.set_parallel().tween_property(liraGroup.material, "shader_parameter/offsets", Vector4(0.0, 0.0, 0.0, 0.0), 0.2).set_trans(Tween.TRANS_QUART)

func restartHealth(): #go back to no heatstrokes but you already suffered major strokes
	for i in $HealthGroup/HealthSeezee/HealthSteps.get_children():
		var healer1 = get_tree().create_tween()
		healer1.tween_property(i, "scale", Vector2(1,1), 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		healer1.set_parallel().tween_property(i, "modulate", Color(1.0,1.0,1.0,1.0), 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func gameOver(): #ow
	await get_tree().create_timer(2, false).timeout
	seezeeIcon.play("Over")
	
	var fuckingbegone = get_tree().create_tween()
	fuckingbegone.tween_property($Color, "color", Color(1.0,1.0,1.0,0.0), 1.0)

func _process(_delta: float) -> void:
	#LIRA TEXT
	if scene.TRUElira != lira:
		lira = lerp(lira, scene.TRUElira, 0.25);
		if abs(lira - scene.TRUElira) <= 5: lira = scene.TRUElira
		powerText.text = str(lira)
	
	#PROGRESS
	liraBar.value = lerp(liraBar.value, float(scene.liraPGR), 0.65)
	if abs(liraBar.value - scene.liraPGR) <= 5: liraBar.value = scene.liraPGR
	
	#SEEZEE ICON FUNCS
	if (seezeeIcon.animation == "Death" or seezeeIcon.animation == "Death_Alt") and not seezeeIcon.is_playing():
		seezeeIcon.play(seezeeIcon.animation + "_Loop")
	
	#DEBUG FUNCS
	if Input.is_key_pressed(KEY_EQUAL): 
		scene.TRUElira += 5;
		scene.liraPGR += 5;
	if Input.is_key_pressed(KEY_MINUS): 
		scene.TRUElira -= 5;
		scene.liraPGR -= 5;
