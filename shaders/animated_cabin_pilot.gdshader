shader_type canvas_item;
render_mode unshaded, blend_mix;
// Mesh vertices, hair, chest and straps move independently in real time.
// The cabin pilot is NOT displayed as a static flat background image.
uniform float anim_time = 0.0;
uniform float long_hair : hint_range(0.0,1.0) = 1.0;
uniform float breath : hint_range(0.0,1.0) = 0.0;

void vertex() {
    float chest = smoothstep(0.18,0.37,UV.y) * (1.0-smoothstep(0.52,0.74,UV.y));
    float scalp = (1.0-smoothstep(0.22,0.52,UV.y)) *
        smoothstep(0.09,0.17,UV.x) * (1.0-smoothstep(0.82,0.93,UV.x));
    float loose_strands = scalp * long_hair *
        (1.0-smoothstep(0.29,0.63,UV.x));
    float fluid = sin(anim_time*0.96+UV.y*8.5+UV.x*4.2);
    VERTEX.x += loose_strands * fluid * 5.0;
    VERTEX.y += scalp * cos(anim_time*0.79+UV.x*4.1)*1.2;
    VERTEX.x += chest * (breath-0.5) * 1.6;
    VERTEX.y += chest * sin(anim_time*1.3) * 0.9;
}
