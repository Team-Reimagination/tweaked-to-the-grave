shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;
uniform int pixel_size = 0;

void fragment()
{
	if (pixel_size > 0) {
		vec2 blocks = (1.0 / SCREEN_PIXEL_SIZE) / float(pixel_size);
		COLOR = texture(SCREEN_TEXTURE, round(SCREEN_UV * blocks) / blocks);
	} else {
		COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	}
}