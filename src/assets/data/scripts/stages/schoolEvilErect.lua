local wiggleShaderCode = [[
extern number uTime;
extern number effectType;
extern number uSpeed;
extern number uFrequency;
extern number uWaveAmplitude;

const int EFFECT_TYPE_DREAMY = 0;
const int EFFECT_TYPE_WAVY = 1;
const int EFFECT_TYPE_HEAT_WAVE_HORIZONTAL = 2;
const int EFFECT_TYPE_HEAT_WAVE_VERTICAL = 3;
const int EFFECT_TYPE_FLAG = 4;

vec2 sineWave(vec2 pt) {
    float x = 0.0;
    float y = 0.0;
            
    if (effectType == EFFECT_TYPE_DREAMY) {
        float w = 1.0 / love_ScreenSize.y;
        float h = 1.0 / love_ScreenSize.x;

        // look mom, I know how to write shaders now

        pt.x = floor(pt.x / h) * h;

        float offsetX = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
    
        pt.y += floor(offsetX / w) * w; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
        pt.y = floor(pt.y / w) * w;

        float offsetY = sin(pt.y * (uFrequency / 2.0) + uTime * (uSpeed / 2.0)) * (uWaveAmplitude / 2.0);
    pt.x += floor(offsetY / h) * h; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
    } else if (effectType == EFFECT_TYPE_WAVY)  {
        float offsetY = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
        pt.y += offsetY; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
    } else if (effectType == EFFECT_TYPE_HEAT_WAVE_HORIZONTAL) {
        x = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
    } else if (effectType == EFFECT_TYPE_HEAT_WAVE_VERTICAL) {
        y = sin(pt.y * uFrequency + uTime * uSpeed) * uWaveAmplitude;
    } else if (effectType == EFFECT_TYPE_FLAG) {
        y = sin(pt.y * uFrequency + 10.0 * pt.x + uTime * uSpeed) * uWaveAmplitude;
        x = sin(pt.x * uFrequency + 5.0 * pt.y + uTime * uSpeed) * uWaveAmplitude;
    }
            
    return vec2(pt.x + x, pt.y + y);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = sineWave(texture_coords);
    return Texel(texture, uv) * color;
}
]]

local WIGGLE_SHADER_TYPE = {
    DREAMY = 0,
    WAVY = 1,
    HEAT_WAVE_HORIZONTAL = 2,
    HEAT_WAVE_VERTICAL = 3,
    FLAG = 4
}

local shaders = {
    wiggleBack = {2 * 0.8, 4 * 0.4, 0.011, WIGGLE_SHADER_TYPE.DREAMY, shader = nil},
    wiggleSchool = {2, 4, 0.017, WIGGLE_SHADER_TYPE.DREAMY, shader = nil},
    wiggleGround = {2, 4, 0.01, WIGGLE_SHADER_TYPE.DREAMY, shader = nil},
    wiggleSpike = {2, 4, 0.007, WIGGLE_SHADER_TYPE.DREAMY, shader = nil}
}

function Stage:build()
    for _, shaderInfo in pairs(shaders) do
        shaderInfo.shader = love.graphics.newShader(wiggleShaderCode)
        shaderInfo.shader:send("effectType", shaderInfo[4])
        shaderInfo.shader:send("uSpeed", shaderInfo[1])
        shaderInfo.shader:send("uFrequency", shaderInfo[2])
        shaderInfo.shader:send("uWaveAmplitude", shaderInfo[3])
    end

    get("school").shader = shaders.wiggleSchool.shader
    get("evilstreet").shader = shaders.wiggleGround.shader
    get("backspikes").shader = shaders.wiggleBack.shader
    get("backspike").shader = shaders.wiggleSpike.shader
end

function Stage:onUpdate(dt)
    for _, shaderInfo in pairs(shaders) do
        shaderInfo.shader:send("uTime", love.timer.getTime())
    end
end
