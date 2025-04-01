extern float colorAlpha;
extern float colorRed;
extern float colorGreen;
extern float colorBlue;

vec4 effect(vec4 colorExt, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 color = Texel(texture, texture_coords);
    
    if (color.a > colorAlpha)
        color.a = colorAlpha;
    if (color.r > colorRed)
        color.r = colorRed;
    if (color.g > colorGreen)
        color.g = colorGreen;
    if (color.b > colorBlue)
        color.b = colorBlue;

    return color;
}
