class_name TTTG_Obstacle
extends TTTG_Entity

@export var canDie = true
@export var camBeHit = true
@export var health = 0;

func _ready() -> void:
	super._ready()
	
	self.area_shape_entered.connect(detectCollission.bind())

func _process(delta: float) -> void:
	super._process(delta)
	
func damage(healthTaken):
	health -= healthTaken
	
	if health <= 0 and canDie:
		imKillingMyself()

func imKillingMyself():
	self.queue_free()

func detectCollission(_areID, are, _arSID, _loSID):
	if are.type == "player_bullet" and camBeHit:
		damage(are.get_meta("power"))
		are.killYourself()
