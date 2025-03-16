extends CanvasLayer

@onready var scene = self.get_parent();
@onready var liraGroup = $LiraGroup
@onready var powerText = $LiraGroup/Lira
@onready var liraBar = $LiraGroup/LiraBar

var lira:int = 0;
var liraMove = 0;
var lirsShakeTween;
var lirsColorTween;

func _ready() -> void:
	powerText.text = str(lira)
	
func _on_tree_entered() -> void:
	liraGroup.material.set("shader_parameter/multipliers", [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0])
	
func levelUpLira():
	if scene.liraLevel < 10:
		liraBar.max_value = scene.liraMax
	else:
		liraBar.max_value = 0
	
	$LiraGroup/LiraParticles.restart()
	$LiraGroup/LevelText.text = "LV "+str(scene.liraLevel)
	
	if scene.liraLevel > 1:
		$LiraGroup/LiraParticles.self_modulate = Color(1.0,1.0,1.0,1.0)
		$LiraGroup/LevelUp.play()
		
		liraMove = 50;
		if lirsShakeTween:
			lirsShakeTween.kill()
		lirsShakeTween = get_tree().create_tween()
		lirsShakeTween.tween_property(self, "liraMove", 0, 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
		liraGroup.material.set("shader_parameter/offsets", Vector4(1.0, 1.0, 1.0, 0.0))
		if lirsColorTween:
			lirsColorTween.kill()
		lirsColorTween = get_tree().create_tween()
		lirsColorTween.tween_property(liraGroup.material, "shader_parameter/offsets", Vector4(0.0, 0.0, 0.0, 0.0), 0.2).set_trans(Tween.TRANS_QUART)

func _process(_delta: float) -> void:
	#LIRA TEXT
	if scene.TRUElira != lira:
		lira = lerp(lira, scene.TRUElira, 0.25);
		if abs(lira - scene.TRUElira) <= 5: lira = scene.TRUElira
		powerText.text = str(lira)
	
	#PROGRESS
	liraBar.value = lerp(liraBar.value, float(scene.liraPGR), 0.65)
	if abs(liraBar.value - scene.liraPGR) <= 5: liraBar.value = scene.liraPGR
	
	#LEVEL UP FUNCS
	if liraMove != 0: liraGroup.position.y = liraMove
	
	#DEBUG FUNCS
	if Input.is_key_pressed(KEY_EQUAL): 
		scene.TRUElira += 5;
		scene.liraPGR += 5;
	if Input.is_key_pressed(KEY_MINUS): 
		scene.TRUElira -= 5;
		scene.liraPGR -= 5;
