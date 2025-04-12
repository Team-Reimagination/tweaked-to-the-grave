extends Node3D

@export var type = 'player_bullet';
@onready var scene = self.get_parent().get_parent();

var isKillingYourself = false

func _ready() -> void:
	self.position = get_meta("spawnPosition")
	rotation_degrees.x = -90
	scale = Vector3(0.8,0.8,0.8)
	
	$Death.volume_db = -10.0 + 10.0 / get_meta("howMany");
	$Death.max_db = $Death.volume_db
	
	self.area_shape_entered.connect(detectCollission.bind())
	
func _process(delta: float) -> void:
	if scene.hasBitchWon:
		$Death.volume_db = -80.0;
		$Death.max_db = $Death.volume_db
	
	if not isKillingYourself:
		position.z -= 400 * delta #movement propossitions

		if position.z < -500: #kill if too far away
			queue_free()
	else:
		if !$Death.playing: queue_free()

func killYourself():
	if not isKillingYourself:
		isKillingYourself = true
		$Death.play()
		$Model.visible = false

func detectCollission(_areID, are, _arSID, _loSID):
	if are.type != 'player_bullet':
		killYourself()
