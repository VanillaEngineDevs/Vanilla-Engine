extern float alpha;

vec4 effect(vec4 colorExt, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 color = Texel(texture, texture_coords);
    if (color.a > 0.0)
        color -= alpha;

    return color;
}