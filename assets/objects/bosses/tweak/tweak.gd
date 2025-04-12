extends TTTG_Boss

var toFlash2

func _ready() -> void:
	super._ready()
	
	toFlash += find_child("Model").find_children("*", "Sprite3D", true, true)

func damage(healthTaken):
	super.damage(healthTaken)

func _process(delta: float) -> void:
	super._process(delta)

func imKillingMyself():
	super.imKillingMyself()
	
	get_tree().create_tween().tween_property(scene.camera, "posi:y", self.position.y + 30 * self.scale.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	
	get_tree().create_tween().tween_property(self, "position", Vector3(self.position.x, self.position.y - 20, self.position.z + 70), 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC).set_delay(3.0)
