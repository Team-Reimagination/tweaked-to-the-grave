shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

const int NumSamples = 10;
uniform float Density = 0.1f;
uniform float Weight = 0.02f;
uniform float illuminationDecay = 0.9f;

void fragment()
{
	vec2 uv = SCREEN_UV;
	
    vec2 delta = uv - vec2(0.5);
    delta *= 1.0f / float(NumSamples) * Density;
	
    vec3 color = texture(SCREEN_TEXTURE, uv).rgb;
    
    for(int i = 0; i < NumSamples; i++)
    {
        uv -= delta;
        vec3 color_sample = texture(SCREEN_TEXTURE, uv).rgb;
        color_sample *= illuminationDecay * Weight;
        
        color += color_sample;
    }

    COLOR = vec4(color, 1);
}