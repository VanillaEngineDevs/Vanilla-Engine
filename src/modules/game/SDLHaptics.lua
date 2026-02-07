local ffi = require("ffi")

ffi.cdef[[
typedef struct SDL_Haptic SDL_Haptic;

enum {
    SDL_HAPTIC_CONSTANT = (1<<0),
    SDL_HAPTIC_SINE     = (1<<1),
    SDL_HAPTIC_LEFTRIGHT = (1<<2),
};

typedef struct SDL_HapticDirection {
    uint8_t type;
    int32_t dir[3];
} SDL_HapticDirection;

typedef struct SDL_HapticConstant {
    uint16_t type;
    SDL_HapticDirection direction;
    int32_t length;
    uint16_t delay;
    uint16_t button;
    uint16_t interval;
    int16_t level;
    uint16_t attack_length;
    uint16_t attack_level;
    uint16_t fade_length;
    uint16_t fade_level;
} SDL_HapticConstant;

typedef struct SDL_HapticEffect {
    uint16_t type;
    SDL_HapticConstant constant;
} SDL_HapticEffect;

int SDL_NumHaptics(void);
SDL_Haptic* SDL_HapticOpen(int index);
int SDL_HapticRumbleInit(SDL_Haptic *haptic);
int SDL_HapticRumblePlay(SDL_Haptic *haptic, float strength, uint32_t length);
void SDL_HapticClose(SDL_Haptic *haptic);
]]

local sdl = ffi.load("SDL2")

local haptics = {
    device = nil
}

function haptics.init()
    if sdl.SDL_NumHaptics() <= 0 then
        return false
    end

    haptics.device = sdl.SDL_HapticOpen(0)
    if haptics.device == nil then
        return false
    end

    sdl.SDL_HapticRumbleInit(haptics.device)
    return true
end

function haptics.rumble(strength, duration)
    if not haptics.device then return end
    sdl.SDL_HapticRumblePlay(
        haptics.device,
        math.max(0, math.min(strength, 1)),
        math.floor(duration * 1000)
    )
end

function haptics.shutdown()
    if haptics.device then
        sdl.SDL_HapticClose(haptics.device)
        haptics.device = nil
    end
end

return haptics
