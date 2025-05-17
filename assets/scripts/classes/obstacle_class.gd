class_name TTTG_Obstacle
extends TTTG_Entity

@export var canDie = true
@export var camBeHit = true
@export var doDamagePlayer = true
@export var isGhost = false
@export var health = 0;

@export var flashIntensity = 1.0

@export var healthLinks : Array[Node3D] = []

var hasBeenLirad = false
var ouchie = false

var toFlash = []

func _ready() -> void:
	self.area_shape_entered.connect(detectCollission.bind())

	if hasModel:
		toFlash = find_child("Model").find_children("*", "MeshInstance3D", true, true).filter(func(x): return x.material_overlay != null)
	
	for a in toFlash:
		a.material_overlay = a.material_overlay.duplicate(true)
	
	super._ready()

func _process(delta: float) -> void:
	if disabled: return
	super._process(delta)
	
func damage(healthTaken, isRecursive = false):
	if disabled: return
	
	if !isRecursive:
		for a in healthLinks:
			if "health" in a and a.has_method("damage") and !a.isGhost: a.damage(healthTaken, true)
	
	health -= healthTaken
	
	if health > 0:
		for a in toFlash:
			a.material_overlay.set("shader_parameter/intensity", flashIntensity);
			get_tree().create_tween().tween_property(a.material_overlay, "shader_parameter/intensity", 0.0, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	
	if health <= 0 and canDie:
		self.area_shape_entered.disconnect(detectCollission.bind())
		imKillingMyself()

func imKillingMyself():
	if disabled: return
	self.queue_free()

func detectCollission(_areID, are, _arSID, _loSID):
	if are.type == "player_bullet" and _loSID == 0 and !disabled:
		if !isGhost:
			if camBeHit: damage(are.get_meta("power") if "power" not in are else are.power)
			are.killYourself()
	
	if !scene.hasBitchWon and !disabled and doDamagePlayer:
		if are.type == "player" and scene.player.canBeHit and _loSID == 0:
			scene.hurtPlayer()
			ouchie = true
			return
		if are.type == "player" and scene.player.canBeHit and _loSID == 1 and !hasBeenLirad and !ouchie:
			await get_tree().create_timer(0.3, false).timeout
			if !ouchie and scene.player.canBeHit:
				scene.hud.bonusing("Right into danger!", 25)
				hasBeenLirad = true
