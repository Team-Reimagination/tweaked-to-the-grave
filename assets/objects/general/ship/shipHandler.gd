extends CharacterBody3D

@onready var scene = self.get_parent().get_parent();

var action = "fly"

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
	2: [0.45, 32.0, 1],
	3: [0.45, 40.0, 1],
	4: [0.4, 40.0, 1],
	5: [0.4, 40.0, 2],
	6: [0.3, 48.0, 2],
	7: [0.3, 56.0, 2],
	8: [0.2, 56.0, 2],
	9: [0.2, 56.0, 2],
	10: [0.1, 56.0, 3],
}
var bltCLD = 0.0;
var bltPWR = 0.0
var bltCNT = 0
var canShoot = true;
var blt = preload("res://assets/objects/bullets/railring/railring.tscn")

func _ready() -> void:
	$Ambience.play()

func levelUpLira():
	if levelTable[scene.liraLevel]:
		bltCLD = levelTable[scene.liraLevel][0]
		bltPWR = levelTable[scene.liraLevel][1]
		bltCNT = levelTable[scene.liraLevel][2]

func _process(_delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	accel = Vector3.ZERO;
	handleInput()
	handleMovement(delta)
	move_and_slide()
	
func handleInput():
	if (action == "fly"):
		leftRight = Input.get_axis("Left_GP", "Right_GP")
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
				
		if Input.is_action_just_pressed("Barrel_GP") and (
			(leftRight < 0 && boundForcefield[0] >= 1.0)
			or
			(leftRight > 0 && boundForcefield[1] >= 1.0)
			or
			(upDown < 0 && boundForcefield[2] >= 1.0)
			or
			(upDown > 0 && boundForcefield[3] >= 1.0)
		):
			action = "barrel"
			velocity.x = maxVel * boundForcefield[1] if leftRight > 0 else -maxVel * boundForcefield[0] * abs(leftRight)
			velocity.y = maxVel * boundForcefield[3] if upDown > 0 else -maxVel * boundForcefield[2] * abs(upDown)
			decel *= barrelDecelMod
			barrelSpin = 360 * 2 * (-1 if leftRight > 0 or upDown > 0 else 1)
			barrelMod = 1.0
			
		if Input.is_action_pressed("Shoot_GP") and canShoot:
			shoot()

	elif (action == "barrel"):
		if abs(barrelMod) < 0.5:
			action = "fly"
			decel /= barrelDecelMod

func handleMovement(delta):
	boundForcefield = [1.0, 1.0, 1.0, 1.0]
	
	if (abs(self.position.x) >= scene.rotateBound):
		if (self.position.x < 0):
			boundForcefield[0] = max(1.0 + (scene.rotateBound + self.position.x)/(scene.maxBoundMod/1.5), 0)
			if (leftRight < 0): velocity.x *= boundForcefield[0]
		else:
			boundForcefield[1] = max(1.0 - (self.position.x - scene.rotateBound)/(scene.maxBoundMod/1.5), 0)
			if (leftRight > 0): velocity.x *= boundForcefield[1]
			
	if (abs(self.position.y) >= scene.vertOffset):
		if (self.position.y < 0):
			boundForcefield[2] = max(1.0 + (scene.vertOffset + self.position.y)/(scene.maxBoundMod/1.5), 0)
			if (upDown < 0): velocity.y *= boundForcefield[2]
		else:
			boundForcefield[3] = max(1.0 - (self.position.y - scene.vertOffset)/(scene.maxBoundMod/1.5), 0)
			if (upDown > 0): velocity.y *= boundForcefield[3]
	
	if accel != Vector3.ZERO:
		velocity += accel * delta;
		
		for i in ["x", "y", "z"]:
			if (abs(velocity[i]) > maxVel): velocity[i] = maxVel if velocity[i] > 0 else -maxVel
			if (abs(velocity[i]) > topVel): velocity[i] = lerpf(velocity[i], (topVel if velocity[i] > 0 else -topVel), 0.3)
		
	for i in ["x", "y", "z"]:
		if abs(accel[i]) < 0.0001:
			velocity[i] = max(0.0, velocity[i] - decel * delta) if velocity[i] > 0 else min(0.0, velocity[i] + decel * delta)
	
	self.rotation_degrees.y = 90
	
	if (action == "fly"):
		self.rotation_degrees.x = lerpf(self.rotation_degrees.x, velocity.x * 0.9, 0.15);
		self.rotation_degrees.z = lerpf(self.rotation_degrees.z, velocity.y * 0.9, 0.15);
	elif (action == "barrel"):
		self.rotation_degrees.x = barrelSpin * barrelMod
		barrelMod = lerp(barrelMod, 0.0, 0.03)
		self.rotation_degrees.z = 0;

func shoot():
	canShoot = false;
	
	var shootFromWhere = $"ShootLines".get_children(true).filter(func(x): return x.get_meta("levelConstrain").has(bltCNT))
	$Shot.play()
	
	for spot in shootFromWhere:
		var bull = blt.instantiate()
		bull.set_meta("power", bltPWR)
		bull.set_meta("spawnPosition", spot.global_position)
		scene.spawnOBJ(bull)
	
	await get_tree().create_timer(bltCLD).timeout
	canShoot = true;
