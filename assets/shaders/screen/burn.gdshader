shader_type canvas_item;

uniform vec2 fireMovement = vec2(-0.01, -0.5);
uniform float distortionStrength = 0.1;

vec2 hash( vec2 p ) {
	p = vec2( dot(p,vec2(127.1,311.7)),
			  dot(p,vec2(269.5,183.3)) );

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p ) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;

	vec2 i = floor( p + (p.x+p.y)*K1 );
	
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = step(a.yx,a.xy);    
    vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;

    vec3 h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );

	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));

    return dot( n, vec3(70.0) );
}

float fbm ( in vec2 p ) {
    float f = 0.0;
    mat2 m = mat2(vec2(1.6,  1.2),vec2(-1.2,  1.6));
    f  = 0.5000*noise(p); p = m*p;
    f += 0.2500*noise(p); p = m*p;
    f += 0.1250*noise(p); p = m*p;
    f += 0.0625*noise(p); p = m*p;
    f = 0.5 + 0.5 * f;
    return f;
}

void fragment() {
	vec2 uv = UV;
	uv.y = 1.0-uv.y;
    vec3 normal = vec3(0.0,0.0,0.0);
    
    vec2 displacement = clamp(vec2(normal.x - .5, (normal.y - .5) * distortionStrength), -2., 3.);
    uv += displacement; 
    
    vec2 uvT = (uv * vec2(1.0, 0.5)) + fireMovement;
    float n = pow(fbm(8.0 * uvT), 1.0);    
    
    float gradient = pow(uv.y - 1.0, 2.0) * 5.;
	if (uv.y > 1.0) gradient = 0.0;
    float finalNoise = n * gradient;
    
    vec3 color = finalNoise * vec3(2.*n, 2.*n*n*n, n*n*n*n);
    COLOR = vec4(color, smoothstep(1.0-color.r, 0.0, 1.0));
}