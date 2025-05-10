shader_type canvas_item;

uniform vec3 Color1 = vec3(0.0, 0.0, 0.0);
uniform float Color1Alpha = 1.0;
uniform vec3 Color2 = vec3(0.0, 0.0, 0.0);
uniform float Color2Alpha = 1.0;
uniform float Dither = 96.0;

vec3 dithered(vec3 color, vec2 uv, float dither) {
    if (dither > 0.0) {
        const vec3 magic = vec3( 10.0, 10.0, 30.0 );
        float f = fract( magic.z * fract( dot( uv, magic.xy ) ) );
        color = clamp(color + (dither/255.0) * f - ((dither*0.5)/255.0), vec3(0.0), vec3(1.0));
    }
    return color;
}

void fragment() {
	//GRADIENT
    vec4 color = mix(vec4(Color1, Color1Alpha), vec4(Color2, Color2Alpha), sin(UV.y));
    vec4 colorDithered = color;
	colorDithered.rgb = dithered(colorDithered.rgb, UV, Dither);

    COLOR = colorDithered;
}