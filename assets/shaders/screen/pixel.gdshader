shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform int pixel_size = 0;

void fragment() {
    if (pixel_size > 0) {
        vec2 uv_scale = floor((1.0 / SCREEN_PIXEL_SIZE) / float(pixel_size));
        vec2 uv_snapped = (floor(SCREEN_UV * uv_scale) + 0.5) / uv_scale;
        COLOR = texture(SCREEN_TEXTURE, uv_snapped);
    } else {
        COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
    }
}