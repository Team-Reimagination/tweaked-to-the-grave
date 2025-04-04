shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

void fragment()
{
	vec2 uv = SCREEN_UV;
	
    vec2 d = abs((uv - 0.5) * 2.0);
    d = pow(d, vec2(2.0, 2.0));
    vec3 frag;
	frag.r = texture(SCREEN_TEXTURE, uv - d * 0.015).r;
    frag.g = texture(SCREEN_TEXTURE, uv).g;
    frag.b = texture(SCREEN_TEXTURE, uv + d * 0.015).b;
    COLOR = texture(SCREEN_TEXTURE, uv) / vec4(3,3,3,3);
    COLOR.rgb = frag.rgb;
}