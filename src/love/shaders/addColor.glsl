extern float colorAlpha;
extern float colorRed;
extern float colorGreen;
extern float colorBlue;

vec4 effect(vec4 colorExt, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 color = Texel(texture, texture_coords);
    
    color.a += colorAlpha;
    color.r += colorRed;
    color.g += colorGreen;
    color.b += colorBlue;

    color = min(color, vec4(1.0, 1.0, 1.0, 1.0));

    return color;
}