shader_type canvas_item;

uniform mat4 multipliers;
uniform vec4 offsets;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

    if (abs(color.a) < 0.00001) {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        color = vec4(color.rgb / color.a, color.a);
        color = offsets + color * multipliers;

        COLOR = vec4(color.rgb * color.a, color.a);
    }
}
