extern vec4 uFrameBounds;
extern float ang;
extern float dist = 15;
extern float str;
extern float thr = 0.1;

extern float angOffset;

extern Image altMask;
extern bool useMask;
extern float thr2;

extern vec3 dropColor;

extern float hue;
extern float saturation;
extern float brightness;
extern float contrast;

extern float AA_STAGES = 2;

const vec3 grayscaleValues = vec3(0.3098039215686275, 0.607843137254902, 0.0823529411764706);
const float e = 2.718281828459045;

extern vec2 textureSize;

vec3 applyHueRotate(vec3 aColor, float aHue){
	float angle = radians(aHue);

	mat3 m1 = mat3(0.213, 0.213, 0.213, 0.715, 0.715, 0.715, 0.072, 0.072, 0.072);
	mat3 m2 = mat3(0.787, -0.213, -0.213, -0.715, 0.285, -0.715, -0.072, -0.072, 0.928);
	mat3 m3 = mat3(-0.213, 0.143, -0.787, -0.715, 0.140, 0.715, 0.928, -0.283, 0.072);
	mat3 m = m1 + cos(angle) * m2 + sin(angle) * m3;

	return m * aColor;
}

vec3 applySaturation(vec3 aColor, float value){
	if(value > 0.0){ value = value * 3.0; }
	value = (1.0 + (value / 100.0));
	vec3 grayscale = vec3(dot(aColor, grayscaleValues));
    return clamp(mix(grayscale, aColor, value), 0.0, 1.0);
}

vec3 applyContrast(vec3 aColor, float value){
	value = (1.0 + (value / 100.0));
		if(value > 1.0){
			value = (((0.00852259 * pow(e, 4.76454 * (value - 1.0))) * 1.01) - 0.0086078159) * 10.0;
			value += 1.0;
		}
  return clamp((aColor - 0.25) * value + 0.25, 0.0, 1.0);
}

vec3 applyHSBCEffect(vec3 color) {
    color += brightness / 250.0;
    color = applyHueRotate(color, hue);
    color = applyContrast(color, contrast);
    color = applySaturation(color, saturation);

    return clamp(color, 0.0, 1.0);
}

vec2 hash22(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

float intensityPass(Image bitmap, vec2 fragCoord, float curThreshold, bool useMask) {
    vec4 col = Texel(bitmap, fragCoord);

    float maskIntensity = 0.0;
    if(useMask == true){
        maskIntensity = mix(0.0, 1.0, Texel(altMask, fragCoord).b);
    }

    if(col.a == 0.0 || (col.r == 0.0 && col.g == 0.0 && col.b == 0.0)){
        return 0.0;
    }


    float intensity = dot(col.rgb, vec3(0.3098, 0.6078, 0.0823));

    intensity = maskIntensity > 0.0 ? float(intensity > thr2) : float(intensity > thr);

    return intensity;
}

float antialias(Image bitmap, vec2 fragCoord, float curThreshold, bool useMask) {
    float center = intensityPass(bitmap, fragCoord, curThreshold, useMask);
    
    if (center < 0.5) return 0.0;

    vec2 texelSize = 1.0 / textureSize;
    vec2 lightDir = normalize(vec2(cos(ang), -sin(ang)));

    const float edgeThreshold = 0.25;
    const int maxSteps = 8;

    float rimFactor = 0.0;

    for (int i = 1; i <= maxSteps; i++) {
        vec2 offsetCoord = fragCoord + lightDir * texelSize * float(i);
        float sample = intensityPass(bitmap, offsetCoord, curThreshold, useMask);

        float diff = center - sample;
        if (diff > edgeThreshold) {
            float falloff = clamp(diff / edgeThreshold, 0.0, 1.0);
            rimFactor = max(rimFactor, falloff);
            break;
        }
    }

    if (rimFactor <= 0.0) return 0.0;

    float AA_JITTER = 0.5;
    const int MAX_AA = 8;
    const int totalPasses = MAX_AA * MAX_AA;
    float result = center;

    for (int i = 0; i < totalPasses; i++) {
        int x = i / MAX_AA;
        int y = i - (MAX_AA * int(x / MAX_AA));

        vec2 jitter = AA_JITTER * (2.0 * hash22(vec2(float(x), float(y))) - 1.0) / textureSize;
        result += intensityPass(bitmap, fragCoord + jitter, curThreshold, useMask);
    }

    result /= float(totalPasses + 1);

    if (true == true) 
        return 0.0; // Temporary until I can fix the rimlight issue

    return mix(center, result, rimFactor);
}

vec3 createDropShadow(Image bitmap, vec3 col, float curThreshold, bool useMask, vec2 fragCoord) {
    float intensity = antialias(bitmap, fragCoord, curThreshold, useMask);
    vec2 imageRatio = vec2(1.0 / love_ScreenSize.x, 1.0 / love_ScreenSize.y);
    vec2 checkedPixel = vec2(fragCoord.x + (dist * cos(ang + angOffset) * imageRatio.x),
                            fragCoord.y - (dist * sin(ang + angOffset) * imageRatio.y));

    float dropShadowAmount = 0.0;
    if(
        checkedPixel.x > uFrameBounds.x && checkedPixel.y > uFrameBounds.y &&
        checkedPixel.x < uFrameBounds.z && checkedPixel.y < uFrameBounds.w
    ){
        dropShadowAmount = Texel(bitmap, checkedPixel).a;
    }

    col.rgb += dropColor.rgb * ((1.0 - (dropShadowAmount * str)) * intensity);
    return col;
}

vec4 effect(vec4 colorExt, Image bitmap, vec2 textureCoord, vec2 screenCoord) {
    vec4 col = Texel(bitmap, textureCoord);

    vec3 unpremultipliedColor = col.a > 0.0 ? col.rgb / col.a : col.rgb;

    vec3 outColor = applyHSBCEffect(unpremultipliedColor);

    outColor = createDropShadow(bitmap, outColor, thr, useMask, textureCoord);

    return vec4(outColor.rgb * col.a, col.a * colorExt.a);
}