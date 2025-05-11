shader_type spatial;
render_mode ambient_light_disabled, unshaded;

uniform sampler2D noise_texture: hint_default_black;
uniform vec2 noise_size = vec2(64.0,64.0);

uniform sampler2D flower_one: hint_default_black;
uniform sampler2D flower_two: hint_default_black;
uniform sampler2D flower_three: hint_default_black;

void fragment() {
	vec4 noise_sample = texture(noise_texture, UV);
    float noise_value = noise_sample.r;
	
	const float black_threshold = 81.0/255.0;
    const float color1_threshold = 169.0/255.0;  // ~525252 / FFFFFF
    const float color2_threshold = 238.0/255.0;  // ~a9a9a9 / FFFFFF
    const float color3_threshold = 255.0/255.0;  // ~eeeeee / FFFFFF
	
	vec2 tiled_uv = UV * noise_size;
	vec4 flower;
	
	if (noise_value <= black_threshold) {
        ALPHA = 0.0;
    } else if (noise_value <= color1_threshold) {
		flower = texture(flower_one, tiled_uv);
        ALBEDO = flower.rgb;
        ALPHA = flower.a;
    } else if (noise_value <= color2_threshold) {
		flower = texture(flower_two, tiled_uv);
        ALBEDO = flower.rgb;
        ALPHA = flower.a;
    } else if (noise_value <= color3_threshold) {
		flower = texture(flower_three, tiled_uv);
        ALBEDO = flower.rgb;
        ALPHA = flower.a;
    } else {
        // Fallback for values above our highest threshold
        ALPHA = 0.0;
    }
}