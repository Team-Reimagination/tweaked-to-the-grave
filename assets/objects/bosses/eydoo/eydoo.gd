extends TTTG_Boss

var toFlash2
var imdying = false

func _ready() -> void:
	super._ready()
	
	overrideDeath = true
	
	toFlash += find_child("Model").find_children("*", "Sprite3D", true, true)

func damage(healthTaken):
	super.damage(healthTaken)

var timey = 0.0

func _process(delta: float) -> void:
	super._process(delta)
	
	timey += delta;
	
	if imdying:
		self.position.z -= 3000 * delta
		self.position.y += 400 * delta
		self.rotation_degrees += Vector3(20,150,1200) * delta
	else:
		if !scene.hasBitchWon: self.position.y = scene.btmF.position.y + 10 + (sin(timey)+1)*5

func imKillingMyself():
	super.imKillingMyself()
	
	get_tree().create_tween().tween_property(scene.camera, "posi:y", self.position.y + 6 * self.scale.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	
	get_tree().create_tween().tween_property(scene.camera, "posi:z", self.position.z + 5 * self.scale.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)

	await get_tree().create_timer(2.0).timeout
	
	scene.shaders.wybielenie(0.5)
	finalHit.play()
	scene.camera.shake(25.0, 1.0)
	
	imdying = true
	
	await get_tree().create_timer(2.0).timeout
	imdying = false
	scene.completeLevel()
	self.queue_free()
