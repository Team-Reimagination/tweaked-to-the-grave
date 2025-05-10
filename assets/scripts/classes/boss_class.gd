class_name TTTG_Boss
extends TTTG_Obstacle

var finalHit = AudioSubtitlableGeneral.new()
var death = AudioSubtitlableGeneral.new()

@export var bossName = "The Tweak"
@export var hasAltDeath = false
@export var altChance = 1.0
@export var overrideDeath = false
@export var deathSubtitle = ""
var hasGotIt = false

func _ready() -> void:
	if disabled: return
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
	finalHit.subtitle = "Final Hit"
	
	if hasAltDeath:
		var rander = randf()
		hasGotIt = rander <= altChance
	
	add_child(death)
	death.add_to_group('Sound')
	death.stream = load("res://assets/sounds/boss/"+scene.bossDEF.type+"_death"+("_alt" if (hasAltDeath and hasGotIt) else "")+".ogg")
	death.max_polyphony = 1;
	death.bus = 'SFX';
	finalHit.subtitle = deathSubtitle

func ImDoneGoodbye(anim):
	if disabled: return
	if anim == 'Death' and !overrideDeath:
		scene.completeLevel()
		self.queue_free()

func _process(delta: float) -> void:
	if disabled: return
	super._process(delta)

func damage(healthTaken):
	if disabled: return
	super.damage(healthTaken)
	
	scene.find_child("HUD").damage()

func imKillingMyself():
	if disabled: return
	scene.scripts.runFunction("onBossDefeat")
	
	PlayGlobals.youarenolongermyfriendsoundnowgoaway()
	finalHit.subtitle_play()
	death.subtitle_play()
		  
	scene.isWarning = false;
	if scene.dial != null: scene.dial.ending()
	
	canDie = false
	camBeHit = false
	scene.hasBitchWon = true
	
	scene.canInput = false;
	scene.canPause = false;
	
	scene.shaders.wybielenie(0.6)
	
	for obj in scene.chunkLoader.get_children():
		if obj is TTTG_Chunk or ("isGameplayObject" in obj and obj.isGameplayObject and obj.has_method("victory_screech")):
			obj.victory_screech()
	
	scene.hud.bossIcon.play("Death")
	self.get_node("Model/AnimationPlayer").play("Death")
	
	if !scene.hasBeenHurt: scene.hud.bonusing("Perfect Bonus!", 2000)
	
	scene.music.stop()
	if !overrideDeath: get_tree().create_tween().tween_property(scene.camera, "posi:z", self.position.z + 50 * self.scale.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
