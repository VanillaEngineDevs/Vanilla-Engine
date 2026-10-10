extern vec3 r;
extern vec3 g;
extern vec3 b;
extern float mult = 1.0;

vec4 effect(vec4 color2, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 color = Texel(texture, texture_coords);

    if (color.a == 0.0 || mult == 0.0) {
        return color;
    }

    vec4 newColor = color;
    newColor.rgb = min(color.r * r + color.g * g + color.b * b, vec3(1.0));
    newColor.a = color.a * color2.a;

    color = mix(color, newColor, mult);

    if (color.a > 0.0) {
        return color;
    }

    return vec4(0.0, 0.0, 0.0, 0.0);
}
