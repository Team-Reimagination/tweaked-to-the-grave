class_name TTTG_Boss
extends TTTG_Obstacle

var finalHit = AudioStreamPlayer.new()
var death = AudioStreamPlayer.new()

@export var hasAltDeath = false
@export var altChance = 1.0
var hasGotIt = false

func _ready() -> void:
	super._ready()
	
	type = 'boss'
	isReady = true
	
	self.get_node("Model/AnimationPlayer").animation_finished.connect(ImDoneGoodbye.bind())

	add_child(finalHit)
	finalHit.add_to_group('Sound')
	finalHit.stream = load("res://assets/sounds/boss/final_boss_hit.ogg")
	finalHit.max_polyphony = 1;
	finalHit.bus = 'SFX';
	finalHit.volume_db = -3.0
	
	if hasAltDeath:
		var rander = randf()
		hasGotIt = rander <= altChance
	
	add_child(death)
	death.add_to_group('Sound')
	death.stream = load("res://assets/sounds/boss/"+scene.bossDEF.type+"_death"+("_alt" if (hasAltDeath and hasGotIt) else "")+".ogg")
	death.max_polyphony = 1;
	death.bus = 'SFX';

func ImDoneGoodbye(anim):
	if anim == 'Death':
		scene.completeLevel()
		self.queue_free()

func _process(delta: float) -> void:
	super._process(delta)

func damage(healthTaken):
	super.damage(healthTaken)
	
	scene.find_child("HUD").damage()

func imKillingMyself():
	PlayGlobals.youarenolongermyfriendsoundnowgoaway()
	finalHit.play()
	death.play()
	
	scene.isWarning = false;
	
	canDie = false
	camBeHit = false
	scene.hasBitchWon = true
	
	scene.canInput = false;
	scene.canPause = false;
	
	scene.shaders.wybielenie(0.6)
	
	scene.hud.bossIcon.play("Death")
	self.get_node("Model/AnimationPlayer").play("Death")
	
	scene.music.stop()
	get_tree().create_tween().tween_property(scene.camera, "posi:z", self.position.z + 50 * self.scale.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
