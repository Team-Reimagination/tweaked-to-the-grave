class_name TTTG_Trailing
extends TTTG_Obstacle

@export var distanceToMove = 500
@export var speed = 1.5

@export var onlyOnce = false
@export var killAfter = false

var timeToMove = false
var hasMoved = false

func _ready() -> void:
	super._ready()
	
func _process(delta:float) -> void:
	if disabled: return
	super._process(delta)
	
	if self.global_position.z > -distanceToMove and !isDying and !timeToMove:
		timeToMove = true
		movemental()

func movemental():
	if disabled: return
	if hasMoved: return
	
	if onlyOnce: 
		hasMoved = true

func victory_screech():
	if disabled: return
	queue_free()

func imKillingMyself():
	if disabled: return
	isGhost = true
	isDying = true
	
	$Unearth.stop()
	$Explosion.visible = true
	$Explosion.play("default")
	
	if !scene.hasBitchWon: $Explode.subtitle_play()
	
	$Shadow.visible = false
	$Model.visible = false
	
	await $Explosion.animation_finished
	queue_free()
