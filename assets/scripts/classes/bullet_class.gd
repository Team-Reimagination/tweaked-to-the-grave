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

@export var doSteer = false
@export var steerPower = 50.0
@export var seekTime = 0.0

var velocity = Vector3.ZERO
var acceleration = Vector3.ZERO

var beenParried
var target
var parent

func _ready() -> void:
	if disabled: return
	super._ready()
	
	velocity = ($Direction.position - $Model.position).normalized() * speed
	velocity = velocity.clampf(-speed, speed)
	
	if doSteer:
		$SeekTimer.start(seekTime)
		target = scene.player

	$AliveTimer.start(lifetime)
	
func seek():
	if disabled: return
	var steer = Vector2.ZERO
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
	look_at(velocity,Vector3.FORWARD)
	position += velocity * delta

func phasingOut():
	if disabled: return
	isDying = true
	for a in 10:
		visible = !visible
		await get_tree().create_timer(0.15, false).timeout
	
	imKillingMyself()

func killYourself():
	if disabled: return
	print(name, "touched")
	imKillingMyself()

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
				
				velocity *= -1 * speed
				velocity = velocity.clampf(-speed, speed)
				
				if parryToParent:
					target = parent
					type = "player_bullet"
			else:
				scene.hurtPlayer()
				ouchie = true
				killYourself()
			return
		if are.type == "player" and scene.player.canBeHit and _loSID == 1 and !hasBeenLirad and !ouchie:
			await get_tree().create_timer(0.3, false).timeout
			if !ouchie:
				scene.hud.bonusing("Right into danger!", 25)
				hasBeenLirad = true

func victory_screech():
	if disabled: return
	queue_free()
