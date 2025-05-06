class_name TTTG_Stomping
extends TTTG_Trailing
var moveTween

func _ready() -> void:
	super._ready()
	
	$Model.position = $MStart.position

func movemental():
	super.movemental()
	if !isDying:
		moveTween = get_tree().create_tween()
		moveTween.set_parallel(true).tween_property($Model, "position", $MEnd.position, speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
		
		await moveTween.finished
		if !isDying: $Thud.play()
