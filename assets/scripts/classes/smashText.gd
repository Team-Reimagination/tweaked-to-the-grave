class_name SmashTextSprite
extends Sprite2D

var tweener
var shaker = 0.0
var globalPos

signal is_exploding
signal is_done_exploding

func _ready() -> void:
	self.self_modulate.a = 0.0
	self.scale *= 1.5;
	
	globalPos = self.global_position
	
func _process(_delta: float) -> void:
	self.global_position = globalPos + Vector2(randf_range(-shaker,shaker),randf_range(-shaker,shaker));

func descend(time,power,release):
	tweener = get_tree().create_tween()
	tweener.set_parallel(true).tween_property(self, "self_modulate:a", 1.0, time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tweener.set_parallel(true).tween_property(self, "scale", self.scale/1.5, time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

	await tweener.finished
	is_exploding.emit()
	
	$Smash.subtitle_play()
	shaker = power
	
	tweener.kill()
	tweener = get_tree().create_tween()
	tweener.tween_property(self, "shaker", 0.0, release).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await tweener.finished
	is_done_exploding.emit()

func ascend(time):
	tweener = get_tree().create_tween()
	tweener.set_parallel(true).tween_property(self, "self_modulate:a", 0.0, time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tweener.set_parallel(true).tween_property(self, "scale", self.scale*1.5, time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
