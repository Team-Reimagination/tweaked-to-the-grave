class_name TTTG_Collectible
extends TTTG_Entity

@export var objType : String
@export var value : int

var startSucking = false
var willDisappear = false

func _ready() -> void:
	super._ready()
	
	if $Model.get_child(1) is AnimatedSprite3D: $Model.get_child(1).play('default')
	
	self.area_shape_entered.connect(detectCollission.bind())

func suicide():
	if disabled: return
	if scene.lives == 0:
		queue_free()
		return
	
	if objType == 'lira' or objType == 'health' or objType == '1up':
		if objType == 'health' and scene.player_health == 0:
			queue_free()
			return
		
		willDisappear = true
		startSucking = false
		
		$CollectAudio.subtitle_play()
		
		overridePos = global_position
		$Model.get_child(1).visible = false
		$Model.get_child(0).visible = true
		
		if objType == 'lira':
			scene.addLira(value)
			$Model.get_child(0).play('default')
		elif objType == 'health':
			scene.heal(1)
			scene.hud.healMe(1)
		elif objType == '1up':
			ole = 0.0
			scene.giveMeLife()
	else:
		queue_free()

var ole = 0.0;
var county = 0

func _process(delta: float) -> void:
	if disabled: return
	super._process(delta)
	
	if willDisappear: 
		if objType == 'lira':
			if $Model.get_child(0).is_playing() == false: queue_free()
		elif objType == 'health':
			$Model.get_child(0).pixel_size += 0.01 * delta
			$Model.get_child(0).modulate.a -= 2 * delta
			
			if $CollectAudio.playing == false: queue_free()
		elif objType == '1up':
			ole += delta
			
			if ole > (1.0 if county == 0 else 0.05):
				ole = 0.0
				self.visible = !self.visible
				county += 1
			
			if county > 10:
				queue_free()
	
	if startSucking and !scene.hasBitchWon:
		ole += delta/2;
		self.global_position.x = lerpf(self.global_position.x, scene.player.global_position.x, ole)
		self.global_position.y = lerpf(self.global_position.y, scene.player.global_position.y, ole)
		self.global_position.z = lerpf(self.global_position.z, scene.player.global_position.z, ole)

func victory_screech():
	if disabled: return
	queue_free()

func detectCollission(_areID, are, _arSID, _loSID):
	if disabled: return
	if !scene.hasBitchWon:
		if are.type == 'player' and _loSID == 0 and !startSucking and !willDisappear and scene.player.action != 'hurt' and scene.player.action != 'explode':
			startSucking = true
			$Attraction.subtitle_play()
		elif are.type == 'player_collector' and _loSID == 1 and !willDisappear and (startSucking or (!startSucking and scene.player.action != 'hurt' and scene.player.action != 'explode')): suicide()
