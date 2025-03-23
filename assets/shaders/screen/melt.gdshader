shader_type canvas_item;

uniform float time = 0.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment()
{
    if (time > 5.0)
        COLOR = vec4(0.0,0.0,0.0,1.0);
    else
    {
        vec2 p = SCREEN_UV;
        float melt = time * 0.2;
		
        float stretch = sin(((p.x*0.5)) * 10.0) * time * 0.2;
        stretch += sin(((p.x*1.3)) * 10.0) * time * 0.1;
        stretch += sin(((p.x*2.4)) * 10.0) * time * 0.05;
		
        vec2 offset = vec2(0., (stretch * stretch) - ((melt * melt * melt) * 3.));
        p += offset;
		
        if (p.y > 1.0 || p.x < 0.0 || p.x > 1.0 || p.y < 0.0)
            COLOR = vec4(0.0,0.0,0.0,1.0);
        else
            COLOR = texture(SCREEN_TEXTURE,p);
    }
}