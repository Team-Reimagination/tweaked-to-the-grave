shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float radius;

void fragment() {
	vec2 uv = UV;

	uv.y = 1.0-uv.y;
    vec2 surface = vec2(0.5, 0.2);
    vec2 center = surface - vec2(0, radius);
    float base = length(uv - center);
    float height = base - radius;
    float xdiff = (uv.x - surface.x) / base * height;
    uv = clamp(vec2 (uv.x - xdiff, surface.y + height), vec2(0.0, 0.0), vec2(1.0, 1.0));
	uv.y = 1.0-uv.y;

    COLOR = texture(SCREEN_TEXTURE, uv);
}
