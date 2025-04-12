class_name TTTG_Boss
extends TTTG_Obstacle

var toFlash

func _ready() -> void:
	super._ready()
	
	toFlash = find_child("Model").find_children("*", "MeshInstance3D", true, true).filter(func(x): return x.material_overlay != null)
	
	self.get_node("Model/AnimationPlayer").animation_finished.connect(ImDoneGoodbye.bind())

func ImDoneGoodbye(anim):
	if anim == 'Death':
		scene.completeLevel()
		self.queue_free()

func _process(delta: float) -> void:
	super._process(delta)

func damage(healthTaken):
	super.damage(healthTaken)
	
	if health > 0:
		for a in toFlash:
			a.material_overlay.set("shader_parameter/intensity", 1.0);
			get_tree().create_tween().tween_property(a.material_overlay, "shader_parameter/intensity", 0.0, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
			
	
	scene.find_child("HUD").damage()

func imKillingMyself():
	canDie = false
	camBeHit = false
	
	scene.canInput = false;
	scene.canPause = false;
	
	scene.hud.bossIcon.play("Death")
	self.get_node("Model/AnimationPlayer").play("Death")
	
	scene.music.stop()
	get_tree().create_tween().tween_property(scene.camera, "posi:z", self.position.z + 50 * self.scale.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
