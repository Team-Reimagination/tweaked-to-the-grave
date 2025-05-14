extends TTTG_Boss

var toFlash2
var haker = false
var screamer = AudioSubtitlableGeneral.new()

func _ready() -> void:
	super._ready()
	
	toFlash += find_child("Model").find_children("*", "Sprite3D", true, true)
	
	add_child(screamer)
	screamer.add_to_group('Sound')
	screamer.stream = load("res://assets/sounds/boss/tweak-final_scream.ogg")
	screamer.max_polyphony = 1;
	screamer.bus = 'Voicelines';
	screamer.subtitle = "\"RAA-\""

func damage(healthTaken, isRecursive = false):
	super.damage(healthTaken, isRecursive)

func _process(delta: float) -> void:
	super._process(delta)
	
	if haker: scene.camera.strength += delta

func imKillingMyself():
	super.imKillingMyself()
	
	get_tree().create_tween().tween_property(scene.camera, "posi:y", self.position.y + 20 * self.scale.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	
	await get_tree().create_timer(2.0).timeout
	haker = true
	scene.player.position.z = -10000
	scene.get_node("./Audio/Earthquake").volume_db = -10.0
	scene.get_node("./Audio/Earthquake").subtitle_play()
		
	await get_tree().create_timer(2.2).timeout
	scene.camera.shake(scene.camera.strength, 1.0);
	haker = false
	
	get_tree().create_tween().tween_property(scene.camera, "posi:z", scene.camera.posi.z + 100, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	get_tree().create_tween().tween_property(scene.get_node("./Audio/Earthquake"), "volume_linear", 0.0, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	
	await get_tree().create_timer(0.6).timeout
	screamer.subtitle_play()
