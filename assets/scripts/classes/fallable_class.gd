class_name TTTG_Fallable
extends TTTG_Obstacle

@export var doSpawn = true
@export var spawnLerp = 0.3
@export var doFall = true
@export var fallDistance = 500
@export var fallTime = 1.0
@export var chosenEase = "in"
@export var chosenTrans = "quart"

var isFalling = false
var isSpawning = true

func _ready() -> void:
	if disabled: return
	super._ready()
	
	$Model.rotation_degrees = $SpawnAngle.rotation_degrees
	$Hitbox.rotation_degrees = $SpawnAngle.rotation_degrees
	$Narrowbox.rotation_degrees = $SpawnAngle.rotation_degrees
	
	$Explosion.visible = false
	
	if doSpawn:
		isGhost = true
		$Shadow.visible = false
		$Model.position = $SpawnAngle.position
		$Hitbox.position = $Hitbox.position
		$Narrowbox.position = $Hitbox.position
	
func _process(delta: float) -> void:
	if disabled: return
	super._process(delta)
	
	if doSpawn and self.global_position.z > -fallDistance:
		$Model.position = lerp($Model.position, $FallAngle.position, spawnLerp)
		$Hitbox.position = $Model.position
		$Narrowbox.position = $Model.position
		
		if !isSpawning:
			isGhost = false
			isSpawning = true
			$Shadow.visible = true
			if $Unearth.stream != null: $Unearth.subtitle_play()
	
	if doFall and !isFalling and self.global_position.z > -fallDistance:
		isFalling = true
		var tweeny = get_tree().create_tween()
		tweeny.tween_property($Model, "rotation_degrees", $FallAngle.rotation_degrees, fallTime).set_ease(PlayGlobals.getEaseType(chosenEase)).set_trans(PlayGlobals.getTransType(chosenTrans))
		tweeny.set_parallel(true).tween_property($Hitbox, "rotation_degrees", $FallAngle.rotation_degrees, fallTime).set_ease(PlayGlobals.getEaseType(chosenEase)).set_trans(PlayGlobals.getTransType(chosenTrans))
		tweeny.set_parallel(true).tween_property($Narrowbox, "rotation_degrees", $FallAngle.rotation_degrees, fallTime).set_ease(PlayGlobals.getEaseType(chosenEase)).set_trans(PlayGlobals.getTransType(chosenTrans))

func victory_screech():
	if disabled: return
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
	
	await $Explosion.animation_finished
	queue_free()
