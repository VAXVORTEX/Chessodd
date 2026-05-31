shader_type canvas_item;

uniform vec2 cloud_direction = vec2(-1.0, 0.5);
uniform float cloud_speed = 0.08;
uniform float cloud_scale = 1.8;
uniform vec4 cloud_color : source_color = vec4(0.0, 0.0, 0.0, 0.45);

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 uv) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(uv);
        uv *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void fragment() {
    vec2 uv = UV * cloud_scale + TIME * cloud_direction * cloud_speed;
    float n = fbm(uv);
    
    // Threshold creates 3-4 distinct blobs instead of fog
    float cloud = smoothstep(0.58, 0.65, n);
    
    COLOR = cloud_color * cloud;
}
