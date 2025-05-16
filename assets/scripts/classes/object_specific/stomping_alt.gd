class_name TTTG_StompingALT
extends TTTG_Trailing

var moveTween

@export var canComeBack = false
@export var stompEase = 'in'
@export var stompTrans = 'circ'

@export var waitTime = 1.0

@export var retractTime = 3.0
@export var releaseEase = 'in'
@export var releaseTrans = 'linear'

func _ready() -> void:
	super._ready()
	
	global_position = $MStart.global_position

func movemental():
	if disabled: return
	
	super.movemental()
	if !isDying:
		moveTween = get_tree().create_tween()
		moveTween.set_parallel(true).tween_property(self, "global_position", $MEnd.global_position, speed).set_ease(PlayGlobals.getEaseType(stompEase)).set_trans(PlayGlobals.getTransType(stompTrans))

		await moveTween.finished
		if disabled: return
		if !isDying and $Thud.stream != null: $Thud.subtitle_play()
	
		if canComeBack:
			returnFunc()
	
func returnFunc():
	await get_tree().create_timer(waitTime, false).timeout
		
	if disabled: return
		
	moveTween = get_tree().create_tween()
	moveTween.set_parallel(true).tween_property(self, "global_position", $MStart.global_position, retractTime).set_ease(PlayGlobals.getEaseType(releaseEase)).set_trans(PlayGlobals.getTransType(releaseTrans))
	
	if !onlyOnce:
		await moveTween.finished
		await get_tree().create_timer(waitTime, false).timeout
			
		if disabled: return
		movemental()
