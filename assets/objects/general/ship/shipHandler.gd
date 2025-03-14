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

func _process(delta: float) -> void:
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
	elif (action == "barrel"):
		if abs(velocity.x) <= topVel/2.0 and abs(velocity.y) <= topVel/2.0:
			action = "fly"
			decel /= barrelDecelMod
		pass

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
		#MAKE ANIMATION HANDLER
		self.rotation_degrees.z = lerpf(self.rotation_degrees.z, velocity.y * 1.2, 0.15);
		pass
