local CONSTANTS = {}

CONSTANTS.OPTIONS = {
    SHOW_RESULTS_SCREEN = true,
    DO_SAVE_DATA = true,
    DO_MODS = true,
}

function hexToRGB(hex)
    local r = bit.band(bit.rshift(hex, 16), 0xFF) / 255
    local g = bit.band(bit.rshift(hex, 8), 0xFF) / 255
    local b = bit.band(hex, 0xFF) / 255
    return r, g, b
end

function decToRGB(dec)
    local r = bit.band(bit.rshift(dec, 16), 0xFF) / 255
    local g = bit.band(bit.rshift(dec, 8), 0xFF) / 255
    local b = bit.band(dec, 0xFF) / 255
    return r, g, b
end

CONSTANTS.RAW_ARROW_COLORS = {
    {0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56},
    {0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7},
    {0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447},
    {0xFFF9393F, 0xFFFFFFFF, 0xFF651038}
}
CONSTANTS.ARROW_COLORS = {}
for i, v in ipairs(CONSTANTS.RAW_ARROW_COLORS) do
    CONSTANTS.ARROW_COLORS[i] = {
        {hexToRGB(v[1])},
        {hexToRGB(v[2])},
        {hexToRGB(v[3])}
    }
end

CONSTANTS.MS_PER_SEC = 1000

CONSTANTS.WEEKS = {
    STRUM_Y = -400,
    STRUM_X_OFFSET = 0,
    PIXELS_PER_MS = 0.45, 
    ANIM_LIST = {
        "singLEFT",
        "singDOWN",
        "singUP",
        "singRIGHT"
    },
    INPUT_LIST = {
        "gameLeft",
        "gameDown",
        "gameUp",
        "gameRight"
    },
    NOTE_LIST = {
        "left",
        "down",
        "up",
        "right"
    },
    EASING_TYPES = {
        ["CLASSIC"] = "out-quad",
        ["linear"] = "linear",
        ["sineIn"] = "in-sine",
        ["sineOut"] = "out-sine",
        ["sineInOut"] = "in-out-sine",
        ["quadIn"] = "in-quad",
        ["quadOut"] = "out-quad",
        ["quadInOut"] = "in-out-quad",
        ["cubicIn"] = "in-cubic",
        ["cubicOut"] = "out-cubic",
        ["cubicInOut"] = "in-out-cubic",
        ["quartIn"] = "in-quart",
        ["quartOut"] = "out-quart",
        ["quartInOut"] = "in-out-quart",
        ["quintIn"] = "in-quintic",
        ["quintOut"] = "out-quintic",
        ["quintInOut"] = "in-out-quintic",
        ["expoIn"] = "in-expo",
        ["expoOut"] = "out-expo",
        ["expoInOut"] = "in-out-expo",
        ["circIn"] = "in-circ",
        ["circOut"] = "out-circ",
        ["circInOut"] = "in-out-circ",
        ["elasticIn"] = "in-elastic",
        ["elasticOut"] = "out-elastic",
        ["elasticInOut"] = "in-out-elastic",
        ["backIn"] = "in-back",
        ["backOut"] = "out-back",
        ["backInOut"] = "in-out-back",
        ["bounceIn"] = "in-bounce",
        ["bounceOut"] = "out-bounce",
        ["bounceInOut"] = "in-out-bounce"
    },
    COUNTDOWN_SOUNDS = {
        "go",
        "one",
        "two",
        "three"
    },
    COUNTDOWN_ANIMS = {
        "go",
        "set",
        "ready"
    },
    JUDGE_THRES = {
        PERFECT_THRES = 5,
        MISS_THRES = 160,
        KILLER_THRES = 12.5,
        SICK_THRES = 45,
        GOOD_THRES = 90,
        BAD_THRES = 135,
        SHIT_THRES = 160
    },
    HEALTH = {
        MAX = 2,
        MIN = 0,
        STARTING = 2 / 2,
        BONUS = {
            KILLER = 2 / 100 * 2,
            SICK = 1.5 / 100 * 2,
            GOOD = 0.75 / 100 * 2,
            BAD = 0 / 100 * 2,
            SHIT = -1 / 100 * 2
        },
        MISS_PENALTY = 4 / 100 * 2,
        GHOST_MISS_PENALTY = 2 / 100 * 2,

        WINNING_THRESHOLD = 0.8 * 2,
        LOSING_THRESHOLD = 0.2 * 2
    },
    MAX_SCORE = 500,
    MIN_SCORE = 0,
    MISS_SCORE = 0,
    SCORING_OFFSET = 54.00,
    SCORING_SLOPE = 0.080,
    LANE_SHADERS = {
        love.graphics.newShader("shaders/RGBPallette.glsl"),
        love.graphics.newShader("shaders/RGBPallette.glsl"),
        love.graphics.newShader("shaders/RGBPallette.glsl"),
        love.graphics.newShader("shaders/RGBPallette.glsl")
    }
}

CONSTANTS.MISC = {
    EMPTY_FUNCTION = function() end
}

return CONSTANTS