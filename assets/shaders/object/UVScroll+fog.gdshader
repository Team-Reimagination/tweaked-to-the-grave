shader_type spatial;
render_mode unshaded,shadows_disabled,ambient_light_disabled,depth_draw_opaque;

uniform sampler2D tex:source_color,filter_nearest_mipmap,repeat_enable;
uniform sampler2D bump_texture:source_color,filter_nearest_mipmap,repeat_enable;
uniform float max_height = 0.1;
uniform vec2 uv_scale = vec2(1.0);
uniform vec2 uv_offset_speed = vec2(0.1, 0.0);
uniform float custom_time;

void vertex() {
    // Calculate UVs with offset and scale (same as fragment)
    vec2 uv = (UV + uv_offset_speed * custom_time);
    
    // Sample bump texture
    float height = texture(bump_texture, UV).r;
    
    // Displace vertex along normal
    VERTEX.y += NORMAL.y * height * max_height;
	
	POSITION = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
}

void fragment() {
  // Apply offset FIRST, then scale
    vec2 uv = (UV + uv_offset_speed * custom_time) * uv_scale;
    
    // Sample texture with corrected UV
    vec4 t3t = texture(tex, uv);
	ALPHA = t3t.a;
    ALBEDO = t3t.rgb;
}