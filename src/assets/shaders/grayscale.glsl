extern float _amount;

vec4 to_grayscale(vec4 input_rgba) {
    float red = (0.2126 + 0.7874 * (1.0 - _amount)) * input_rgba.r + (0.7152 - 0.7152  * (1.0 - _amount)) * input_rgba.g + (0.0722 - 0.0722 * (1.0 - _amount)) * input_rgba.b;
    float green = (0.2126 - 0.2126 * (1.0 - _amount)) * input_rgba.r + (0.7152 + 0.2848  * (1.0 - _amount)) * input_rgba.g + (0.0722 - 0.0722 * (1.0 - _amount)) * input_rgba.b;
    float blue = (0.2126 - 0.2126 * (1.0 - _amount)) * input_rgba.r + (0.7152 - 0.7152  * (1.0 - _amount)) * input_rgba.g + (0.0722 + 0.9278 * (1.0 - _amount)) * input_rgba.b;

    return vec4(red, green, blue, input_rgba.a);
}

vec4 effect(vec4 colorExt, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 color = Texel(texture, texture_coords);

    color = to_grayscale(color);

    return color;
}