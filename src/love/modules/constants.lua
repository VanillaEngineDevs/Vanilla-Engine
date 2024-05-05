local CONSTANTS = {}

CONSTANTS.WEEKS = {
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
    }
}

return CONSTANTS