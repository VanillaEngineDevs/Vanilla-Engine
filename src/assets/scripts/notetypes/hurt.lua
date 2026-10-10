return {
    -- The name of the note type found in the chart
    name = "Hurt Note",

    -- Use the default colours if r, g, or b are nil (will only supply the default for the specific rgb value that is nil)
    -- Colours are formatted with Hexadecimal notation: 0xRRGGBB or decimal notation: -16119286
    r = 0xFF101010,
    g = 0xFFFF0000,
    b = 0xFF990022,

    -- If disableRGB is true, the r, g, and b values will be ignored and will use the image with no rgb palette shader
    disableRGB = false,

    -- If ignoreNote is true, the note can not be hit by the enemy or the player
    ignoreNote = false,

    -- healthMult and healthLossMult are multipliers for the health of the player
    healthMult = -10,
    healthLossMult = 0,

    -- If causesMiss is true, the note will cause a miss if hit by the player (wont be hit by the enemy regardless of ignoreNote)
    causesMiss = true,

    -- imagePath, the path to the image that will be used
    -- if nil, will use the default image
    imagePath = nil,

    -- mainSprite, the lua sprite chunk file that will be used
    -- if nil, will use the "left", "down", "up", "right" sprites
    -- if those are nil, will use the default sprite
    mainSprite = nil,

    leftSprite = nil,
    downSprite = nil,
    upSprite = nil,
    rightSprite = nil,

    -- splashSprite, the lua sprite chunk file that will be used
    -- if nil, will use the default splash sprite (will be pixel splash when in a pixel week, otherwise will be a normal splash)
    splashSprite = nil,

    -- holdCover, the lua sprite chunk file that will be used
    -- if nil, will use the default hold cover sprite
    holdCover = nil,
}