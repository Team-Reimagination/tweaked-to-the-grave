extends TTTG_FallingBullet

var rotato = 0


func _process(delta: float) -> void:
	super._process(delta)
	
	rotato += int(1000 * delta * (1 if velocity.x > 0 else -1 if velocity.x < 0 else 0)) % 360
	rotation_degrees.z = -180 + rotato
	rotation.x = 0.0
	rotation.y = 0.0
