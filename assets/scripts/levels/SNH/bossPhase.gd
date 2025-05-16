extends Node

@onready var scene = get_parent().get_parent()

var startingPhase2 = false
var haker = false

var myWoodJustGotLonger = false
var attackingYourMom = false
var enxtPhase = 0.8;

var goString = "bobttott";
var goIndex = 0;

var madden = AudioSubtitlableGeneral.new()
var hell = AudioSubtitlableGeneral.new()

var bossy = load("res://assets/data/chunks/"+PlayGlobals.levelID+"/boss.tscn")
var bossAttacks;
var waitTime = 1.5
var attackWait = Timer.new()
var attacks = []

func _ready() -> void:
	add_child(madden)
	madden.add_to_group('Sound')
	madden.stream = load("res://assets/sounds/boss/tweak-final_mad.ogg")
	madden.max_polyphony = 1;
	madden.bus = 'Voicelines';
	madden.subtitle = "Tweak Getting Rage"
	
	add_child(hell)
	hell.add_to_group('Sound')
	hell.stream = load("res://assets/sounds/boss/tweak-final_hell.ogg")
	hell.max_polyphony = 1;
	hell.bus = 'Voicelines';
	hell.subtitle = "Tweak's Screams Of Hell"
	
	# Attacks Node
	bossy = bossy.instantiate()
	bossAttacks = bossy.get_children()
	
	for a in bossAttacks:
		a.owner = null
		a.get_parent().remove_child(a)
	
	add_child(attackWait)
	attackWait.one_shot = true

func _process(delta) :
	if scene.hasBitchWon:
		return
	
	if ["Attack_Slam, Attack_Grow_Return", "Attack_Side_Return"].find(scene.boss.get_node("Model/AnimationPlayer").current_animation) != -1 and !scene.boss.get_node("Model/AnimationPlayer").is_playing():
		scene.boss.get_node("Model/AnimationPlayer").play("Mad_Idle")
		
	if haker:
		scene.camera.strength += 1.0 * delta
		
	if myWoodJustGotLonger and !attackingYourMom and attackWait.time_left <= 0.0001:
		var chara = goString.substr(goIndex, 1)
		
		attackingYourMom = true
		initiateAttack(chara)
		
		goIndex += 1
		if goIndex >= len(goString): goIndex = 0
	
	if (scene.boss.health / scene.bossDEF.health <= enxtPhase and !startingPhase2) or (OS.is_debug_build() and Input.is_key_pressed(KEY_0) and !startingPhase2):
		startingPhase2 = true
		
		scene.chunkLoader.lvChunks = []
		scene.shaders.wybielenie(0.5)
		
		for obj in scene.chunkLoader.get_children():
			if obj is TTTG_Chunk or ("isGameplayObject" in obj and obj.isGameplayObject and obj.has_method("victory_screech")):
				obj.victory_screech()
		
		scene.boss.get_node("Model/AnimationPlayer").play("Reeling")
		scene.canInput = false
		
		if scene.dial != null:
			scene.dial.dialEventNum = 999999
			scene.dial.checkDialogue()
		
		var tweeny = get_tree().create_tween()
		tweeny.set_parallel(true).tween_property(scene.camera, "posi:z", scene.boss.global_position.z + 100, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tweeny.set_parallel(true).tween_property(scene.camera, "posi:y", scene.camera.posi.y + 10, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		tweeny.set_parallel(true).tween_property(scene.music, "volume_linear", 0.0, 1.0)
		tweeny.set_parallel(true).tween_property(scene, "scrollMod", 0.0, 1.0)
		
		await tweeny.finished
		await get_tree().create_timer(1.0, false).timeout
		
		haker = true
		
		madden.subtitle_play()
		
		scene.boss.get_node("Model/AnimationPlayer").play("Mad")
		scene.get_node("./Audio/Earthquake").volume_db = -10.0
		scene.get_node("./Audio/Earthquake").subtitle_play()
		
		await scene.boss.get_node("Model/AnimationPlayer").animation_finished
		
		haker = false
		scene.get_node("./Audio/Earthquake").stop()
		scene.shaders.wybielenie(0.5)
		scene.camera.shake(50.0, 2.0)
		scene.boss.get_node("Model/AnimationPlayer").play("Scream")
		
		
		scene.music.stop();
		scene.music.stream = load("res://assets/music/levels/SNH_Pinch.ogg")
		
		hell.subtitle_play()
		
		tweeny = get_tree().create_tween()
		tweeny.tween_property(scene.camera, "posi:z", scene.boss.global_position.z + 150, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
		tweeny.set_parallel(true).tween_property(scene.camera, "posi:y", scene.camera.posi.y - 10, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
		
		tweeny.tween_property(scene.camera, "posi:z", 0.0, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART).set_delay(0.5)
		tweeny.set_parallel(true).tween_property(scene.boss, "global_position:z", -150, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART).set_delay(0.5)
		tweeny.set_parallel(true).tween_property(scene, "scrollMod", 5.0, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART).set_delay(0.5)
		
		await scene.boss.get_node("Model/AnimationPlayer").animation_finished
		scene.canInput = true
		scene.boss.get_node("Model/AnimationPlayer").play("Mad_Idle")
		scene.music.play()
		scene.music.volume_db = -15.0
		scene.loadDialogue("SNH_Phase2")
		
		myWoodJustGotLonger = true
		attackWait.start(waitTime)

func onGameOver(_vars):
	for atk in attacks: if atk != null: atk.queue_free()
	queue_free()

func onBossDefeat(_vars):
	for atk in attacks: if atk != null: atk.queue_free()
	queue_free()

func initiateAttack(charo):
	scene.boss.get_node("Model/AnimationPlayer").stop(true)
	
	if charo == 'o':
		scene.boss.get_node("Model/AnimationPlayer").play("Attack_Grow")
		scene.boss.get_node("./Audio/BreatheIn").subtitle_play()
		
		await get_tree().create_timer(0.5, false).timeout
		scene.boss.get_node("./Audio/Whistle").subtitle_play()
		var att = createAttack(0)
		
		att.global_position.x = scene.player.global_position.x
		att.global_position.y = scene.player.global_position.y
		
		await get_tree().create_timer(3.0, false).timeout
		scene.boss.get_node("Model/AnimationPlayer").play("Attack_Grow_Return")
	elif charo == 'b':
		scene.boss.get_node("Model/AnimationPlayer").play("Attack_Slam", -1, 0.7)
		
		scene.boss.get_node("./Audio/Lift").subtitle_play()
		
		createAttack(1)
		await get_tree().create_timer(1.8, false).timeout
		scene.boss.get_node("./Audio/Drop").subtitle_play()
	elif charo == 't':
		scene.boss.get_node("Model/AnimationPlayer").play("Attack_Side", -1, 0.7)
		scene.boss.get_node("./Audio/TakeThis").subtitle_play()
		createAttack(2)
		
		await get_tree().create_timer(3.0, false).timeout
		scene.boss.get_node("Model/AnimationPlayer").play("Attack_Side_Return")
	
func prepForAnother():
	attackingYourMom = false
	waitTime = randf_range(0.15, 0.4) / max(0.001, enxtPhase / 
	(scene.boss.health / scene.bossDEF.health))
	attackWait.start(waitTime)
	
func createAttack(index):
	var attack = bossAttacks[index].duplicate()
	scene.spawnOBJ(attack)
	for a in attack.get_children(true):
		a = a.duplicate()
		
	attack.global_position = Vector3(0.0, 4.0, -20.0)
	attack.visible = true
	
	attacks.push_back(attack)
	
	attack.attack_complete.connect(prepForAnother.bind())
	
	return attack;
