shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

//Bloom Settings
//BLOOM_THRESHOLD - how bright a pixel needs to be to become blurred
//BLOOM_INTENSITY - how bright the bloom effect is
uniform float BLOOM_THRESHOLD = 0.1;
uniform float  BLOOM_INTENSITY = 1;

//Blur Settings
//BLUR_ITERATIONS - how many times a blur is created
//BLUR_SIZE - the radius of the bloom
//BLUR_SUBDIVISIONS - how many times the texture is sampled per iteration
uniform int  BLUR_ITERATIONS = 5;
uniform float  BLUR_SIZE = 0.2;
uniform int  BLUR_SUBDIVISIONS = 48;

vec3 getHDR(vec3 tex) {
    return max((tex - BLOOM_THRESHOLD) * vec3(BLOOM_INTENSITY,BLOOM_INTENSITY,BLOOM_INTENSITY), 0.);
}

vec3 gaussian(sampler2D sampler, vec2 uv) {
    vec3 sum = vec3(0.);
    
    for(int i = 1; i <= BLUR_ITERATIONS; i++) {
        float angle = 360. / float(BLUR_SUBDIVISIONS);
        
        for(int j = 0; j < BLUR_SUBDIVISIONS; j++) {
            float dist = BLUR_SIZE * (float(i+1) / float(BLUR_ITERATIONS));
            float s    = sin(angle * float(j));
            float c       = cos(angle * float(j));
            
            sum += getHDR(texture(sampler, uv + vec2(c,s)*dist).xyz);
        }
    }
    sum /= float(BLUR_ITERATIONS * BLUR_SUBDIVISIONS);
    return sum * vec3(BLOOM_INTENSITY,BLOOM_INTENSITY,BLOOM_INTENSITY);
}

vec3 blend(vec3 a, vec3 b) {
    return 1. - (1. - a)*(1. - b);
}

void fragment()
{
	vec2 uv = SCREEN_UV;
    vec4 tx = texture(SCREEN_TEXTURE, uv);
    
    COLOR.rgb = gaussian(SCREEN_TEXTURE, uv) * (1. - tx.rgb);
    COLOR.a   = tx.a;
    COLOR.rgb = blend(tx.rgb, COLOR.rgb);
}