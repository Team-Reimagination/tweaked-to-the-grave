extends Node

@onready var scene = get_parent().get_parent()

var startingPhase2 = false
var haker = false

var madden = AudioSubtitlableGeneral.new()
var hell = AudioSubtitlableGeneral.new()

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

func _process(delta) :
	if scene.hasBitchWon:
		return
		
	if haker:
		scene.camera.strength += 1.0 * delta
	
	if (scene.boss.health / scene.bossDEF.health <= 2.0/3.0 and !startingPhase2) or (OS.is_debug_build() and Input.is_key_pressed(KEY_0) and !startingPhase2):
		startingPhase2 = true
		
		scene.boss.get_node("Model/AnimationPlayer").play("Reeling")
		scene.canInput = false
		
		if scene.dial != null:
			scene.dial.dialEventNum = 999999
			scene.dial.checkDialogue()
		
		var tweeny = get_tree().create_tween()
		tweeny.set_parallel(true).tween_property(scene.camera, "posi:z", scene.boss.global_position.z + 100, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		tweeny.set_parallel(true).tween_property(scene.camera, "posi:y", scene.camera.posi.y + 10, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		tweeny.set_parallel(true).tween_property(scene.music, "volume_linear", 0.0, 1.0)
		
		await tweeny.finished
		await get_tree().create_timer(1.0).timeout
		
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
		tweeny.tween_property(scene.camera, "posi:z", scene.boss.global_position.z + 150, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		
		tweeny.tween_property(scene.camera, "posi:z", 0.0, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART).set_delay(0.5)
		tweeny.set_parallel(true).tween_property(scene.camera, "posi:y", scene.camera.posi.y - 10, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART).set_delay(0.5)
		tweeny.set_parallel(true).tween_property(scene.boss, "global_position:z", -200, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART).set_delay(0.5)
		
		await scene.boss.get_node("Model/AnimationPlayer").animation_finished
		scene.canInput = true
		scene.boss.get_node("Model/AnimationPlayer").play("Mad_Idle")
		scene.music.play()
		scene.music.volume_db = -15.0
		scene.loadDialogue("SNH_Phase2")

func onBossDefeat(_vars):
	queue_free()
