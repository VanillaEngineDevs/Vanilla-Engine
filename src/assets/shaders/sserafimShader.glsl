extern float hue;
extern float saturation;
extern float brightness;
extern float contrast;

extern float darkAmt;
extern vec3 lightColor;
extern float pulseStrength;
extern float truckStrength;
extern bool isChar;

const vec3 grayscaleValues = vec3(
    0.3098039215686275,
    0.607843137254902,
    0.0823529411764706
);

const float e = 2.718281828459045;

vec3 applyHueRotate(vec3 aColor, float aHue)
{
    float angle = radians(aHue);

    mat3 m1 = mat3(
        0.213, 0.213, 0.213,
        0.715, 0.715, 0.715,
        0.072, 0.072, 0.072
    );

    mat3 m2 = mat3(
        0.787, -0.213, -0.213,
       -0.715,  0.285, -0.715,
       -0.072, -0.072,  0.928
    );

    mat3 m3 = mat3(
       -0.213,  0.143, -0.787,
       -0.715,  0.140,  0.715,
        0.928, -0.283,  0.072
    );

    mat3 m = m1 + cos(angle) * m2 + sin(angle) * m3;
    return m * aColor;
}

vec3 applySaturation(vec3 aColor, float value)
{
    if (value > 0.0)
        value *= 3.0;

    value = 1.0 + (value / 100.0);
    vec3 grayscale = vec3(dot(aColor, grayscaleValues));

    return clamp(mix(grayscale, aColor, value), 0.0, 1.0);
}

vec3 applyContrast(vec3 aColor, float value)
{
    value = 1.0 + (value / 100.0);

    if (value > 1.0)
    {
        value = (((0.00852259 * pow(e, 4.76454 * (value - 1.0))) * 1.01)
                - 0.0086078159) * 10.0;
        value += 1.0;
    }

    return clamp((aColor - 0.25) * value + 0.25, 0.0, 1.0);
}

vec3 applyHSBCEffect(vec3 color)
{
    color += brightness / 255.0;
    color = applyHueRotate(color, hue);
    color = applyContrast(color, contrast);
    color = applySaturation(color, saturation);
    return color;
}

#define saturate(v) clamp(v, 0.0, 1.0)

vec3 hue2rgb(float h)
{
    h = fract(h);
    return saturate(vec3(
        abs(h * 6.0 - 3.0) - 1.0,
        2.0 - abs(h * 6.0 - 2.0),
        2.0 - abs(h * 6.0 - 4.0)
    ));
}

vec3 rgb2hsl(vec3 c)
{
    float cMin = min(min(c.r, c.g), c.b);
    float cMax = max(max(c.r, c.g), c.b);
    float delta = cMax - cMin;

    vec3 hsl = vec3(0.0, 0.0, (cMax + cMin) * 0.5);

    if (delta != 0.0)
    {
        if (hsl.z < 0.5)
            hsl.y = delta / (cMax + cMin);
        else
            hsl.y = delta / (2.0 - cMax - cMin);

        float dR = (((cMax - c.r) / 6.0) + (delta / 2.0)) / delta;
        float dG = (((cMax - c.g) / 6.0) + (delta / 2.0)) / delta;
        float dB = (((cMax - c.b) / 6.0) + (delta / 2.0)) / delta;

        if (c.r == cMax)
            hsl.x = dB - dG;
        else if (c.g == cMax)
            hsl.x = (1.0 / 3.0) + dR - dB;
        else
            hsl.x = (2.0 / 3.0) + dG - dR;

        hsl.x = fract(hsl.x);
    }

    return hsl;
}

vec3 hsl2rgb(vec3 hsl)
{
    if (hsl.y == 0.0)
        return vec3(hsl.z);

    float b = (hsl.z < 0.5)
        ? hsl.z * (1.0 + hsl.y)
        : hsl.z + hsl.y - hsl.y * hsl.z;

    float a = 2.0 * hsl.z - b;
    return a + hue2rgb(hsl.x) * (b - a);
}

const float lightMultiplier = 0.07;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc)
{
    vec4 col = Texel(tex, tc) * color;

    vec3 unpremultiplied =
        col.a > 0.0 ? col.rgb / col.a : col.rgb;

    vec3 outColor = applyHSBCEffect(unpremultiplied);

    float combinedAlpha = truckStrength + pulseStrength;

    float darkFactor = combinedAlpha * lightMultiplier + darkAmt;
    if (darkAmt > 0.65)
        darkFactor = combinedAlpha * (-lightMultiplier) + darkAmt;

    vec3 bruhColor = rgb2hsl(lightColor);
    bruhColor.b *= pulseStrength;
    bruhColor = hsl2rgb(bruhColor);

    vec3 multiplyColor;

    if (isChar)
    {
        multiplyColor = mix(vec3(1.0), vec3(0.0), darkFactor / 5.0);
        multiplyColor = mix(multiplyColor, bruhColor, darkFactor / 3.0);
    }
    else
    {
        multiplyColor = mix(vec3(1.0), vec3(0.0), darkFactor);
        multiplyColor = mix(multiplyColor, bruhColor, darkFactor / 2.0);
    }

    outColor *= multiplyColor;

    return vec4(outColor * col.a, col.a);
}
