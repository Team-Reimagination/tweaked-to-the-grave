shader_type spatial;
render_mode ambient_light_disabled;

// Gradient textures for diffuse and specular lighting
uniform sampler2D albedo_texture : hint_default_white;
uniform sampler2D diffuse_gradient;
uniform sampler2D specular_gradient;

void fragment() {
    // Sample base albedo texture
    ALBEDO = texture(albedo_texture, UV).rgb;
}

void light() {
    float diffuse_intensity = clamp((dot(NORMAL, LIGHT)+1.0)/2.0, 0.0, 1.0);
	
    vec3 diffuse_color = texture(diffuse_gradient, vec2(diffuse_intensity, 0.0)).rgb;
	vec3 specular_color = texture(specular_gradient, vec2(diffuse_intensity, 0.0)).rgb;
    
    DIFFUSE_LIGHT = ALBEDO.rgb * diffuse_color + specular_color;
}