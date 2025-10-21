shader_type canvas_item;

uniform float barPos = 1.0;
const float colors[12] = float[12](255.0/255.0,  182.0/255.0,  182.0/255.0,
	                              202.0/255.0,  116.0/255.0,  170.0/255.0,
	                              137.0/255.0,  35.0/255.0,   156.0/255.0,
	                              33.0/255.0,   0.0/255.0,    56.0/255.0);

void fragment() {
    vec4 color = vec4(0.0,0.0,0.0,0.0);

    for (int i = 0; i < 3; i++) {
        float subtract = 0.0;
        if (i == 1) subtract = 25.0;
        if (i == 2) subtract = 30.0;

        float specBarPos = (barPos - 0.1) * (1.3 + float(i)*0.5);
        float skewX = UV.y/8.0;

        float minDis = specBarPos + skewX;
        float midDis = 1.0/(40.0 - subtract) * (1.0 + float(i)*0.2)/3.0 + specBarPos + skewX;
        float maxDis = 1.0/(40.0 - subtract) + specBarPos + skewX;

        if (UV.x > minDis && UV.x <= midDis) color = vec4(colors[3*i + 0], colors[3*i + 1], colors[3*i + 2], 1.0);
        else if (UV.x > midDis && UV.x <= maxDis) color = vec4(colors[3*i + 3], colors[3*i + 4], colors[3*i + 5], 1.0);

        if (i == 2 && UV.x > maxDis) color = vec4(0.0, 0.0, 0.0, 1.0);
    }

    COLOR = color;
}