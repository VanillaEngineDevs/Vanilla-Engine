/* const int EFFECT_TYPE_DREAMY = 0;
const int EFFECT_TYPE_WAVY = 1;
const int EFFECT_TYPE_HEAT_WAVE_HORIZONTAL = 2;
const int EFFECT_TYPE_HEAT_WAVE_VERTICAL = 3;
const int EFFECT_TYPE_FLAG = 4; */

extern float uTime;
//extern float effectType;
extern float uSpeed;
extern float uFrequency;
extern float uWaveAmplitude;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    
    float w = 1.0 / 311;
    float h = 1.0 / 161;

    uv.x = floor(uv.x / h) * h;

    float offsetX = sin(uv.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;

    uv.y += floor(offsetX / w) * w;
    uv.y = floor(uv.y / w) * w;

    float offsetY = sin(uv.y * (uFrequency / 2.0) + uTime * (uSpeed / 2.0)) * (uWaveAmplitude / 2.0);
    uv.x += floor(offsetY / h) * h;

    return Texel(texture, uv);
}