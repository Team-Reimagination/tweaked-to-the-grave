class_name TTTG_Bullet
extends TTTG_Obstacle

@export var parryable = false
@export var offscreenCheck = false
@export var rotateBullet = false
@export var power = 10.0
@export var speed = 1.0
@export var lifetime = 1.0

@export var parryToParent = false
@export var parrySpeed = 1.5
@export var parryPower = 1.5

@export var doParryX = true
@export var doParryY = false
@export var doParryZ = true

@export var doSteer = false
@export var steerPower = 50.0
@export var seekTime = 10.0

@export var overrideXRot = -INF
@export var overrideYRot = -INF
@export var overrideZRot = -INF

var velocity = Vector3.ZERO
var acceleration = Vector3.ZERO

var beenParried
var target
@export var parent : Node3D

func _ready() -> void:
	if disabled: return
	super._ready()
	
	velocity = ($Direction.global_position - $Model.global_position).normalized() * speed
	velocity = velocity.clampf(-speed, speed)
	
	if doSteer:
		$SeekTimer.start(seekTime)
		target = scene.player
	
	if rotateBullet:
		look_at(velocity,Vector3.FORWARD)

	$AliveTimer.start(lifetime)
	
func seek():
	if disabled or parent == null: return Vector3.ZERO
	var steer = Vector3.ZERO
	if target:
		var desired = (target.global_position - global_position).normalized() * speed
		steer = (desired - velocity).normalized() * steerPower
		return steer
	
func _process(delta: float) -> void:
	if disabled: return
	super._process(delta)
	
	if offscreenCheck and !$Offscreen.is_on_screen():
		imKillingMyself()

	if $AliveTimer.time_left <= 0.0001 and !isDying:
		phasingOut()
	
	if doSteer and $SeekTimer.time_left <= 0.0001:
		doSteer = false
		
	if beenParried and $ParryTimer.time_left <= 0.0001:
		beenParried = false

func _physics_process(delta):
	if disabled: return
	
	if doSteer: acceleration += seek()
	
	velocity += acceleration * delta
	velocity = velocity.clampf(-speed, speed)
	if rotateBullet: look_at(velocity,Vector3.FORWARD)
	
	position += velocity * delta

	if overrideXRot != -INF: rotation_degrees.x = overrideXRot
	if overrideYRot != -INF: rotation_degrees.y = overrideYRot
	if overrideZRot != -INF: rotation_degrees.z = overrideZRot

func phasingOut():
	if disabled: return
	isDying = true
	for a in 10:
		visible = !visible
		await get_tree().create_timer(0.15, false).timeout
	
	imKillingMyself()

func killYourself():
	if disabled: return
	imKillingMyself()

func imKillingMyself():
	queue_free()

func detectCollission(_areID, are, _arSID, _loSID):
	if disabled: return
	if !scene.hasBitchWon:
		if are.type == "player" and scene.player.canBeHit and _loSID == 0:
			if parryable and !beenParried and scene.player.action == "barrel":
				if $Parry.stream != null: $Parry.subtitle_play()
				beenParried = true
				
				$ParryTimer.start(0.5)
				speed *= parrySpeed
				power *= parryPower
				
				if doParryX:
					velocity.x *= -1 * speed
				if doParryY:
					velocity.y *= -1 * speed
				if doParryZ:
					velocity.z *= -1 * speed
					
				velocity = velocity.clampf(-speed, speed)
				
				type = "player_bullet"
				scene.hud.bonusing("Parried!", 50)
				hasBeenLirad = true
				
				if parryToParent:
					target = parent
					$SeekTimer.start(seekTime)
					doSteer = true
					
			else:
				scene.hurtPlayer()
				ouchie = true
				killYourself()
			return
		if are.type == "player" and scene.player.canBeHit and _loSID == 1 and !hasBeenLirad and !ouchie:
			await get_tree().create_timer(0.3, false).timeout
			if !ouchie and !hasBeenLirad:
				scene.hud.bonusing("Right into danger!", 25)
				hasBeenLirad = true

func victory_screech():
	queue_free()
