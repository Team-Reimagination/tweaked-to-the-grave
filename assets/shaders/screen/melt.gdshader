shader_type canvas_item;

uniform float time = 0.0;
uniform float radius = 100.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

void fragment()
{
    vec2 uv = FRAGCOORD.xy/(1.0 / SCREEN_PIXEL_SIZE);
    vec4 tex1 = texture(SCREEN_TEXTURE,uv);

	uv.x += 0.6;
    float cord = smoothstep(0.,.1,sin(uv.x*1.+cos(uv.y+time)*radius*(uv.x-0.5))+sin(uv.x+time)*radius*(uv.x-.5));

    vec3 col = tex1.rgb*clamp(cord,0.,1.);

    COLOR = vec4(col,1.0);
}