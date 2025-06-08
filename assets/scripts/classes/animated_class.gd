class_name TTTG_Animated
extends TTTG_Obstacle

@export var spawnDistance = 500
@export var animName = "ArmatureAction"
@export var animSpeed = 1.0
@export var loopName = ""
@export var loopSpeed = 1.0
@export var narrowboxID = 1
var isSpawning = false

func reset(isRecursive = false):
	super.reset(isRecursive)
	
	isSpawning = false
	
	isGhost = true
	$Model/AnimationPlayer.play(animName, -1, 0.0)
	
	$Explosion.visible = false
	$Shadow.visible = true
	$Model.visible = true
	
	isDying = false

func _ready() -> void:
	super._ready()
	
	$Model/AnimationPlayer.play(animName, -1, 0.0)
	
	isGhost = true
	
func _process(delta: float) -> void:
	if disabled: return
	super._process(delta)
	
	if !isSpawning and self.global_position.z > -spawnDistance:
		isGhost = false
		isSpawning = true
		if $Unearth.stream != null: $Unearth.subtitle_play()
		
		$Model/AnimationPlayer.play(animName, -1, animSpeed)
		
		await $Model/AnimationPlayer.animation_finished
		if loopName != "": $Model/AnimationPlayer.play(loopName, -1, loopSpeed)
	
func victory_screech():
	queue_free()

func imKillingMyself():
	if disabled: return
	isGhost = true
	isDying = true
	
	if $Unearth.stream != null: $Unearth.stop()
	$Explosion.visible = true
	$Explosion.play("default")
	
	if !scene.hasBitchWon: $Explode.subtitle_play()
	
	$Shadow.visible = false
	$Model.visible = false
	
	disabled = true
	await $Explosion.animation_finished

func detectCollission(_areID, are, _arSID, _loSID):
	if disabled: return
	if are.type == "player_bullet" and _loSID < narrowboxID:
		if !isGhost:
			if camBeHit: damage(are.get_meta("power") if "power" not in are else are.power)
			are.killYourself()
		
	if !scene.hasBitchWon:
		if are.type == "player" and scene.player.canBeHit and _loSID < narrowboxID:
			scene.hurtPlayer()
			ouchie = true
			return
		if are.type == "player" and scene.player.canBeHit and _loSID >= narrowboxID and !hasBeenLirad and !ouchie:
			await get_tree().create_timer(0.3, false).timeout
			if !ouchie and scene.player.canBeHit:
				scene.hud.bonusing("Right into danger!", 25)
				hasBeenLirad = true
