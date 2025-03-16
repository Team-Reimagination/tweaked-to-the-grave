extends CanvasLayer

@onready var scene = self.get_parent();
@onready var powerText = $Powers

var lira:int = 0;

func _ready() -> void:
	powerText.text = str(lira)

func _process(_delta: float) -> void:
	if scene.TRUElira != lira:
		lira = lerp(lira, scene.TRUElira, 0.25);
		if abs(lira - scene.TRUElira) <= 5: lira = scene.TRUElira
		powerText.text = str(lira)
		
	if Input.is_key_pressed(KEY_EQUAL): 
		scene.TRUElira += 100;
		scene.liraPGR += 100;
	if Input.is_key_pressed(KEY_MINUS): 
		scene.TRUElira -= 100;
		scene.liraPGR += 100;
