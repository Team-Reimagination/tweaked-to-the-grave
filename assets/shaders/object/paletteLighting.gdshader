shader_type spatial;
render_mode ambient_light_disabled;

// Gradient textures for diffuse and specular lighting
uniform sampler2D albedo_texture : hint_default_white;
uniform sampler2D diffuse_gradient: hint_default_black;
uniform sampler2D specular_gradient: hint_default_black;

uniform sampler2D emissive_texture: hint_default_black;

uniform float fade_start = 0.0; // Distance where fading begins
uniform float fade_end = 0.0;   // Distance where object becomes fully transparent

void fragment() {
    // Sample base albedo texture
    ALBEDO = texture(albedo_texture, UV).rgb;
	
	float fade_distance = length(VERTEX.z);

	const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
	float fade = clamp(smoothstep(fade_start, fade_end, fade_distance), 0.0, 1.0);
	
	if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
		discard;
	}
}

void light() {
    float diffuse_intensity = clamp((dot(NORMAL, LIGHT)+1.0)/2.0, 0.0, 1.0);
	
    vec3 diffuse_color = texture(diffuse_gradient, vec2(diffuse_intensity, 0.0)).rgb;
	vec3 specular_color = texture(specular_gradient, vec2(diffuse_intensity, 0.0)).rgb;
	
	vec4 emissive_tex = texture(emissive_texture, UV);
	vec3 emissive_color = emissive_tex.rgb * emissive_tex.a;
    
    DIFFUSE_LIGHT = (ALBEDO.rgb * diffuse_color); //diffuse
	DIFFUSE_LIGHT += specular_color; //specular
	DIFFUSE_LIGHT = min(DIFFUSE_LIGHT + emissive_color, 1.0);//emissive
}