extends CharacterBody3D

@export var type = 'player';
@onready var scene = $"../.."

var action = "fly"
var canBeHit = true

# movement speed
var speed = 50;
var accel = Input.get_vector("Left_GP", "Right_GP", "Down_GP", "Up_GP");

#velocities
var vel = Vector3.ZERO
var topVel = 30;
var maxVel = 90;

#deleration when at standstill and strength of speed when turning around
var decel = 50;
var barrelDecelMod = 2.5
var turnAroundMod = 2.3;
var boundForcefield = [1.0, 1.0, 1.0, 1.0];

#individual handlers
var leftRight;
var upDown;

#Barrel Roll
var barrelSpin = 0.0;
var barrelMod = 1.0;

#Weapon
var levelTable = {
	1: [0.5, 32.0, 1],
	2: [0.5, 34.0, 1],
	3: [0.45, 40.0, 1],
	4: [0.45, 44.0, 1],
	5: [0.4, 48.0, 2],
	6: [0.4, 52.0, 2],
	7: [0.35, 56.0, 2],
	8: [0.33, 60.0, 2],
	9: [0.3, 64.0, 2],
	10: [0.2, 70.0, 3],
}
var bltCLD = 0.0;
var bltPWR = 0.0
var bltCNT = 0
var canShoot = true;
@onready var autofire = SaveSystem.optionsData.gameplay_autofire

func _ready() -> void:
	$Ambience.play()
	$Model/AnimationPlayer.play("ArmatureAction")

func levelUpLira(): #upgrade new powers bsaed on level
	if levelTable[scene.liraLevel]:
		bltCLD = levelTable[scene.liraLevel][0] * PlayGlobals.bulletCooldown
		bltPWR = levelTable[scene.liraLevel][1] / PlayGlobals.bulletPower
		bltCNT = levelTable[scene.liraLevel][2]
	
func _physics_process(delta: float) -> void:
	accel = Vector3.ZERO;
	handleInput()
	handleMovement(delta)
	move_and_slide()
	
func handleInput():
	if scene.canInput:
		if (action == "fly"):
			leftRight = Input.get_axis("Left_GP", "Right_GP") #analog support for direction i believe
			upDown = Input.get_axis("Down_GP", "Up_GP")
			
			if (abs(leftRight) > 0.00001) :
				if leftRight < 0: #left
					accel.x = -speed * (1.0 if accel.x > 0 else turnAroundMod) * abs(leftRight) * boundForcefield[0]
				if leftRight > 0: #right
					accel.x = speed * (1.0 if accel.x < 0 else turnAroundMod) * abs(leftRight) * boundForcefield[1]
					
			if (abs(upDown) > 0.00001) :
				if upDown < 0: #down
					accel.y = -speed * (1.0 if accel.y > 0 else turnAroundMod) * abs(upDown) * boundForcefield[2]
				if upDown > 0: #up
					accel.y = speed * (1.0 if accel.y < 0 else turnAroundMod) * abs(upDown) * boundForcefield[3]
					
			if Input.is_action_just_pressed("Barrel_GP") and ( #if about to barrel and are not holding the direction the invisible forcefield is preventing from doing
				(leftRight < 0 && boundForcefield[0] >= 1.0)
				or
				(leftRight > 0 && boundForcefield[1] >= 1.0)
				or
				(upDown < 0 && boundForcefield[2] >= 1.0)
				or
				(upDown > 0 && boundForcefield[3] >= 1.0)
			) and PlayGlobals.canBarrelRoll:
				$Barrelroll.play()
				$Barrelroll.pitch_scale = randf_range(0.75,1.25)
				
				action = "barrel" #do acts and immediately change speed
				velocity.x = maxVel * boundForcefield[1] if leftRight > 0 else -maxVel * boundForcefield[0] * abs(leftRight)
				velocity.y = maxVel * boundForcefield[3] if upDown > 0 else -maxVel * boundForcefield[2] * abs(upDown)
				decel *= barrelDecelMod
				barrelSpin = 360 * 2 * (-1 if leftRight > 0 or upDown > 0 else 1)
				barrelMod = 1.0
		elif (action == "barrel"): #if barreling but almost run out of barrel juices (nooo my barrel juices)
			if abs(barrelMod) < 0.5:
				action = "fly"
				quitBarrel()
		elif (action == "hurt"): #outchie but almost out of booboos
			if hurtSpinMod < 0.5:
				action = "fly"
				invincibilityFrames()
				
		if action == 'fly' or (action == 'barrel' and PlayGlobals.canBarrelShoot):
			if (Input.is_action_pressed("Shoot_GP") or autofire == true) and canShoot:
				shoot()
				
		#DEBUG FUNCS
		if Input.is_physical_key_pressed(KEY_BACKSPACE) and canBeHit: 
			scene.hurtPlayer()
			scene.hurtPlayer()
			scene.hurtPlayer()

var hurtSpin:float = 0;
var hurtSpinMod:float = 0;

func gameOver():
	pass

func quitBarrel(): #revert back the increased develeration
	decel /= barrelDecelMod

func handleMovement(delta):
	boundForcefield = [1.0, 1.0, 1.0, 1.0] #invisible forcefield
	
	#horizontal forcefield
	#controlled by position detection but affects movement when inputing or when hurt
	if (abs(self.position.x) >= scene.rotateBound):
		if (self.position.x < 0):
			boundForcefield[0] = max(1.0 + (scene.rotateBound + self.position.x)/(scene.maxBoundMod/1.5), 0) 
			if (leftRight < 0 or (action == 'hurt' and boundForcefield[0] < 1.0)): velocity.x *= boundForcefield[0]
		else:
			boundForcefield[1] = max(1.0 - (self.position.x - scene.rotateBound)/(scene.maxBoundMod/1.5), 0)
			if (leftRight > 0 or (action == 'hurt' and boundForcefield[1] < 1.0)): velocity.x *= boundForcefield[1]
			
	#vertical forcefield that is slightly different in detection because the camera is placed in a place when the elephant is 0,0,-20
	#controlled by position detection but affects movement when inputing or when hurt
	if (abs(self.position.y) >= scene.vertOffset):
		if (self.position.y < 0):
			boundForcefield[2] = max(1.0 + (scene.vertOffset + self.position.y)/(scene.maxBoundMod/1.5), 0)
			if (upDown < 0 or (action == 'hurt' and boundForcefield[2] < 1.0)): velocity.y *= boundForcefield[2]
		else:
			boundForcefield[3] = max(1.0 - (self.position.y - scene.vertOffset)/(scene.maxBoundMod/1.5), 0)
			if (upDown > 0 or (action == 'hurt' and boundForcefield[3] < 1.0)): velocity.y *= boundForcefield[3]
	
	if accel != Vector3.ZERO:
		velocity += accel * delta; #movement propositions
		
		for i in ["x", "y", "z"]: #max and toppies
			if (abs(velocity[i]) > maxVel): velocity[i] = maxVel if velocity[i] > 0 else -maxVel
			if (abs(velocity[i]) > topVel): velocity[i] = lerpf(velocity[i], (topVel if velocity[i] > 0 else -topVel), 0.3)
		
	if action != "hurt" and action != 'explode': #if not hurting, decelerate normally
		for i in ["x", "y", "z"]:
			if abs(accel[i]) < 0.0001:
				velocity[i] = max(0.0, velocity[i] - decel * delta) if velocity[i] > 0 else min(0.0, velocity[i] + decel * delta)
	
	self.rotation_degrees.y = 90 #constant
	
	#rotation modes per action
	if action == "fly":
		self.rotation_degrees.x = lerpf(self.rotation_degrees.x, velocity.x * 0.9, 0.15);
		self.rotation_degrees.z = lerpf(self.rotation_degrees.z, velocity.y * 0.9, 0.15);
	elif action == "barrel":
		self.rotation_degrees.x = barrelSpin * barrelMod
		barrelMod = lerp(barrelMod, 0.0, 0.03)
		self.rotation_degrees.z = lerpf(self.rotation_degrees.z, 0, 0.15);
	elif action == "hurt":
		hurtSpin += delta*25
		hurtSpinMod = lerpf(hurtSpinMod, 0.0, 0.05)
		self.rotation_degrees.z = lerpf(self.rotation_degrees.z, 0, 0.15);
		self.rotation_degrees.x = sin(hurtSpin) * hurtSpinMod

var blt = preload("res://assets/objects/bullets/railring/railring.tscn")
func shoot():
	canShoot = false;
	
	#get places to shoot from depending on level and shoot from there
	var shootFromWhere = $"ShootLines".get_children(true).filter(func(x): return x.get_meta("levelConstrain").has(bltCNT))
	$Shot.play()
	$Shot.pitch_scale = randf_range(0.75,1.25)
	
	for spot in shootFromWhere:
		var bull = blt.instantiate()
		bull.set_meta("power", bltPWR)
		bull.set_meta("spawnPosition", spot.global_position)
		bull.set_meta("howMany", bltCNT)
		scene.spawnOBJ(bull)
	
	await get_tree().create_timer(bltCLD, false).timeout
	canShoot = true;

func hurtPlayer():
	if action == "barrel": #chande deceleration, dangeroud
		decel /= barrelDecelMod
		
	canBeHit = false
	action = "hurt"
	hurtSpin = 0;
	hurtSpinMod = 25;
	
	$Hurt.play()
	$Hurt.pitch_scale = randf_range(0.85,1.15)
	
	velocity = -velocity
	if velocity == Vector3.ZERO: 
		velocity = Vector3(randf_range(-5,5),randf_range(-5,5),0)
		
	for i in ["x", "y", "z"]:
		velocity[i] = clampf(velocity[i], -5.0, 5.0)
	
	accel = Vector3.ZERO
	
func loseLife():
	if action == "barrel":
		decel /= barrelDecelMod
		
	canBeHit = false
	action = "explode"
	velocity = Vector3.ZERO
	accel = Vector3.ZERO
	
	$Ambience.stop()
	
	self.rotation_degrees.z = 0
	self.rotation_degrees.x = 0
	self.visible = false
	
	$Explode.play()
	
	if (scene.lives > 0):
		await get_tree().create_timer(1.5, false).timeout
		action = "fly"
		
		scene.restartHealth()
		$"../../HUD".restartHealth()
		
		$Ambience.play()
		invincibilityFrames()

func invincibilityFrames(isVisible = true): #custom flicker function
	$"../../HUD".updateIcon()
	
	self.visible = not self.visible
	for num in range(13):
		await get_tree().create_timer(0.1, false).timeout
		self.visible = not self.visible
	
	self.visible = isVisible

	canBeHit = true

func startLevel(): #starting
	position.z = 0;
	get_tree().create_tween().tween_property(self, "position:z", -20.0, 0.75).set_ease(Tween.EASE_OUT).set_delay(1.5).set_trans(Tween.TRANS_CIRC)
