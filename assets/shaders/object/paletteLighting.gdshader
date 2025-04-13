shader_type spatial;
render_mode ambient_light_disabled;

// Gradient textures for diffuse and specular lighting
uniform sampler2D albedo_texture : hint_default_white;
uniform sampler2D diffuse_gradient: hint_default_black;
uniform sampler2D specular_gradient: hint_default_black;

uniform sampler2D emissive_texture: hint_default_black;

void fragment() {
    // Sample base albedo texture
    ALBEDO = texture(albedo_texture, UV).rgb;
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