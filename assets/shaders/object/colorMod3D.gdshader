shader_type spatial;
render_mode unshaded;

uniform sampler2D tex:source_color,filter_linear_mipmap,repeat_disable;
uniform vec3 flash_color:source_color = vec3(1.0);
uniform float intensity:hint_range(0.0, 1.0, 0.1) = 0.0;
uniform bool doTransparency = true;

void fragment() {
	vec4 tex_color = texture(tex, UV);
	ALBEDO = mix(tex_color.rgb, flash_color, intensity);
	if (doTransparency) tex_color.a *= intensity;
	ALPHA = tex_color.a;
}