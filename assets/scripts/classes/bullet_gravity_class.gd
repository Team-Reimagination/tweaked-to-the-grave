class_name TTTG_FallingBullet
extends TTTG_Bullet

@export var gravityMod = 1.0

func _physics_process(delta):
	if disabled: return
	if doSteer: acceleration += seek()
	
	velocity += acceleration * delta
	velocity.y -= PlayGlobals.gravity * gravityMod * delta
	velocity = velocity.clampf(-speed, speed)
	look_at(velocity,Vector3.FORWARD)
	position += velocity * delta
