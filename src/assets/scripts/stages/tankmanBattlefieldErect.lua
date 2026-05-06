local colorShader

local function randomBool(chance)
    return love.math.random() < (chance / 100)
end

function Stage:addCharacter(char, name)
    colorShader = colorShader or love.graphics.newShader("shaders/adjustColor.glsl")

    colorShader:send("brightness", -46)
    colorShader:send("hue", -38)
    colorShader:send("contrast", -25)
    colorShader:send("saturation", -20)

    char.shader = colorShader
end

function Stage:onBeatHit(beat)
    if randomBool(2) then
        get("sniper"):play("sip", false, false)
    end
end
