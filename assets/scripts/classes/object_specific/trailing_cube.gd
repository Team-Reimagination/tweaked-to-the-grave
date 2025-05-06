class_name TTTG_TrailingCube
extends TTTG_Trailing
var moveTween

var switcherooni = false

func movemental():
	super.movemental()
	
	if !isDying:
		var positional = $MEnd.global_position - $MStart.global_position
		var anglature = $MEnd.global_rotation - $MStart.global_rotation
		
		moveTween = get_tree().create_tween()
		moveTween.set_parallel(true).tween_property($Model, "global_transform:basis", $Model.global_transform.basis * Basis.from_euler(anglature), speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
		moveTween.set_parallel(true).tween_property(self, "position", position + positional, speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
		
		await moveTween.finished
		if !isDying:
			$Thud.play()
			if !hasMoved: movemental()
