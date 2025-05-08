extends Node

@onready var scene = get_parent().get_parent()
var readying = Sprite2D.new()
var boom = AudioSubtitlableGeneral.new()

func onDialogue(vars):
	if vars[0] == 6:
		readying.texture = load("res://assets/images/entities/eydoo/standready.png")
		
		scene.hud.topLayer.add_child(readying)
		readying.position = Vector2(640, 480)
		
		add_child(boom)
		boom.add_to_group('Sound')
		boom.stream = load("res://assets/sounds/misc/vine_boom.ogg")
		boom.max_polyphony = 1;
		boom.bus = 'SFX';
		boom.volume_db = -3.0
		boom.subtitle = "Vine Boom"
		boom.subtitle_play()
		
		var twa = get_tree().create_tween().tween_property(readying, "modulate:a", 0.0, 1.0)
		
		await twa.finished
		readying.queue_free()
		queue_free()
