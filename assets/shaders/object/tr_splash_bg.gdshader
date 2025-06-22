shader_type canvas_item;

#define PI 3.14159265358

const vec4 Color1 = vec4(134.0/255.0, 117.0/255.0, 225.0/255.0, 1.0);
const vec4 Color2 = vec4(189.0/255.0, 243.0/255.0, 245.0/255.0, 1.0);
const float Dither = 96.0;

uniform float redFloat = -1.0;
uniform float greenFloat = -0.5;
uniform float blueFloat = 1.0;
uniform float redAdd = 0;
uniform float greenAdd = -128;
uniform float blueAdd = -255;

uniform float checkAlpha = 0.0;

vec3 dithered(vec3 color, vec2 uv, float dither) {
    if (dither > 0.0) {
        const vec3 magic = vec3( 10.0, 10.0, 30.0 );
        float f = fract( magic.z * fract( dot( uv, magic.xy ) ) );
        color = clamp(color + (dither/255.0) * f - ((dither*0.5)/255.0), vec3(0.0), vec3(1.0));
    }
    return color;
}

vec3 subtract(vec3 target, vec3 blend) {
    return target - blend;
}

void fragment() {
    //GRADIENT
    vec4 color = mix(Color1, Color2, sin(UV.y*PI));
    vec4 colorDithered = color;
	colorDithered.rgb = dithered(colorDithered.rgb, UV, Dither);
    
    //CHECKERBOARD
    float checkSize = 1.0 / 7.0;
    
    vec2 pos = floor(vec2(UV.x * (1.0 * 1.35) + TIME / 6.0, UV.y) / checkSize);
    float checkMask = mod(pos.x + mod(pos.y, 2.0), 2.0);
    vec4 gradColor = checkMask * vec4(255.0/255.0, 153.0/255.0, 204.0/255.0, checkAlpha);
    
    COLOR = vec4(subtract(colorDithered.rgb, gradColor.rgb * gradColor.a), 1.0);

    COLOR.rgb *= vec3(redFloat, greenFloat, blueFloat);
    COLOR.rgb += vec3(redAdd, greenAdd, blueAdd) / 255.0;
}