class_name TTTG_Obstacle
extends TTTG_Entity

@export var canDie = true
@export var camBeHit = true
@export var health = 0;

var toFlash = []

func _ready() -> void:
	super._ready()
	
	toFlash = find_child("Model").find_children("*", "MeshInstance3D", true, true).filter(func(x): return x.material_overlay != null)
	
	self.area_shape_entered.connect(detectCollission.bind())

func _process(delta: float) -> void:
	super._process(delta)
	
func damage(healthTaken):
	health -= healthTaken
	
	if health > 0:
		for a in toFlash:
			a.material_overlay.set("shader_parameter/intensity", 1.0);
			get_tree().create_tween().tween_property(a.material_overlay, "shader_parameter/intensity", 0.0, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	
	if health <= 0 and canDie:
		imKillingMyself()

func imKillingMyself():
	self.queue_free()

func detectCollission(_areID, are, _arSID, _loSID):
	if are.type == "player_bullet" and camBeHit:
		damage(are.get_meta("power"))
