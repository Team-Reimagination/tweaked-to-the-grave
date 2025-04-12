shader_type spatial;

void fragment() {
	ALPHA = 1.0;
}

void vertex() {
	VERTEX.y = cos(VERTEX.x) * sin(VERTEX.z);
}