return {
    -- The name of the note type found in the chart
    name = "normal",

    -- Use the default colours if r, g, or b are nil (will only supply the default for the specific rgb value that is nil)
    -- Colours are formatted with Hexadecimal notation: 0xRRGGBB or decimal notation: -16119286
    r = nil,
    g = nil,
    b = nil,

    -- If disableRGB is true, the r, g, and b values will be ignored and will use the image with no rgb palette shader
    disableRGB = false,

    -- If ignoreNote is true, the note can not be hit by the enemy or the player
    ignoreNote = false,

    -- healthMult and healthLossMult are multipliers for the health of the player
    healthMult = 1,
    healthLossMult = 1,

    -- If causesMiss is true, the note will cause a miss if hit by the player (wont be hit by the enemy regardless of ignoreNote)
    causesMiss = false,

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