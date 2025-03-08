shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform mat4 multipliers;
uniform vec4 offsets;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);

    if (abs(color.a) < 0.00001) {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        color = vec4(color.rgb / color.a, color.a);
        color = offsets + color * multipliers;

        COLOR = vec4(color.rgb * color.a, color.a);
    }
}
