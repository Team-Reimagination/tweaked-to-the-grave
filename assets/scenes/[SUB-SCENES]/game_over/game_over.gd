extends CanvasLayer

@onready var grad = $Gradient
@onready var title = $Title
@onready var gamo = $Text
@onready var buttons = $Buttons

var isItReady = false

func start() -> void:
	Subtitles.setPlacementY()
	Subtitles.setPlacementX()
	$SoOver.subtitle_play()
	
	#this is so jank but it works, just don't fucking do this
	var gra = get_parent().create_tween()
	gra.tween_property($BG, "color", Color(0.0,0.0,0.0,0.5), 0.2)
	
	var gradT = get_parent().create_tween()
	gradT.tween_property(grad, "scale:y", 1.5, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var gradT2 = get_parent().create_tween()
	gradT2.tween_property(grad, "scale:x", 20.5, 3.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var gradT3 = get_parent().create_tween()
	gradT3.tween_property(title, "scale:x", 1, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var gradT4 = get_parent().create_tween()
	gradT4.tween_property(grad, "self_modulate", Color(1.0,1.0,1.0,0.0), 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	
	gradT.tween_property(gamo, "self_modulate", Color(1.0,1.0,1.0,1.0), 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).set_delay(0.4)
	gradT3.tween_property(gamo, "position:y", gamo.position.y + 20, 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(1.2).timeout
	$Stroked.subtitle_play()
	
	await get_tree().create_timer(1.0).timeout
	buttons.canInput = true
	buttons.updateButtonSelection()
	buttons.updateScale()

func _process(_delta: float) -> void:
	if not isItReady:
		isItReady = true
		start()
		
	if buttons.canInput and $Stroked.playing == false and $Music.volume_db < 0.0:
		$Music.play()
		$Music.volume_db = 0.0;
