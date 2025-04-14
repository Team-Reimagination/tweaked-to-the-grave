shader_type spatial;
render_mode unshaded,shadows_disabled,ambient_light_disabled;

uniform sampler2D tex:source_color,filter_nearest_mipmap,repeat_enable;
uniform vec2 uv_scale = vec2(1.0);
uniform vec2 uv_offset_speed = vec2(0.1, 0.0);
uniform float custom_time;

void fragment() {
  // Apply offset FIRST, then scale
    vec2 uv = (UV + uv_offset_speed * custom_time) * uv_scale;
    
    // Sample texture with corrected UV
    vec4 t3t = texture(tex, uv);
	ALPHA = t3t.a;
    ALBEDO = t3t.rgb;
}