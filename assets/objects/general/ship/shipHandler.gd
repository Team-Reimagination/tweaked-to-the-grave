extends CharacterBody3D

var speed = 40;
var accel = Input.get_vector("Left_GP", "Right_GP", "Down_GP", "Up_GP");
var vel = Vector3.ZERO
var decel = 30;
var turnAroundMod = 2.3;

var leftRight;
var upDown

func _physics_process(delta: float) -> void:
	accel = Vector3.ZERO;
	
	#INPUT HANDLER
	leftRight = Input.get_axis("Left_GP", "Right_GP")
	upDown = Input.get_axis("Down_GP", "Up_GP")
	
	if (abs(leftRight) > 0.00001) :
		if leftRight < 0:
			accel.x = -speed * (1.0 if accel.x > 0 else turnAroundMod) * abs(leftRight)
		if leftRight > 0:
			accel.x = speed * (1.0 if accel.x < 0 else turnAroundMod) * abs(leftRight)
			
	if (abs(upDown) > 0.00001) :
		if upDown < 0:
			accel.y = -speed * (1.0 if accel.y > 0 else turnAroundMod) * abs(upDown)
		if upDown > 0:
			accel.y = speed * (1.0 if accel.y < 0 else turnAroundMod) * abs(upDown)
	
	#MOVEMENT HANDLER
	if accel != Vector3.ZERO:
		velocity += accel * delta;
		
	for i in ["x", "y", "z"]:
		if abs(accel[i]) < 0.0001:
			velocity[i] = max(0.0, velocity[i] - decel * delta) if velocity[i] > 0 else min(0.0, velocity[i] + decel * delta)
	
	self.rotation.x = velocity.x / 80;
	self.rotation.z = velocity.y / 80;
	move_and_slide()
