shader_type spatial;
render_mode unshaded,shadows_disabled,ambient_light_disabled,fog_disabled;

uniform sampler2D tex:source_color,filter_nearest_mipmap,repeat_enable;
uniform vec2 uv_scale = vec2(1.0);
uniform vec2 uv_offset_speed = vec2(0.1, 0.0);
uniform float fade_start = 10.0; // Distance where fading begins
uniform float fade_end = 20.0;   // Distance where object becomes fully transparent
uniform float custom_time;

void fragment() {
  // Apply offset FIRST, then scale
    vec2 uv = (UV + uv_offset_speed * custom_time) * uv_scale;
    
    // Sample texture with corrected UV
    vec4 t3t = texture(tex, uv);
	ALPHA = t3t.a;
    ALBEDO = t3t.rgb;
	
	{
		// Distance Fade: Pixel Dither
		float fade_distance = length(VERTEX.xz);

		// Use interleaved gradient noise, which is fast but still looks good.
		const vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
		float fade = clamp(smoothstep(fade_start, fade_end, fade_distance), 0.0, 1.0);
		// Use a hard cap to prevent a few stray pixels from remaining when past the fade-out distance.
		if (fade < 0.001 || fade < fract(magic.z * fract(dot(FRAGCOORD.xy, magic.xy)))) {
			discard;
		}
	}
}