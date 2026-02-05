local colorShaderBF, colorShaderDad, colorShaderGF

function Stage:build()
    colorShaderBF = love.graphics.newShader("shaders/adjustColor.glsl")
    colorShaderDad = love.graphics.newShader("shaders/adjustColor.glsl")
    colorShaderGF = love.graphics.newShader("shaders/adjustColor.glsl")

    colorShaderBF:send("brightness", -23)
    colorShaderBF:send("hue", 12)
    colorShaderBF:send("contrast", 7)

    colorShaderGF:send("brightness", -30)
    colorShaderGF:send("hue", -9)
    colorShaderGF:send("contrast", -4)

    colorShaderDad:send("brightness", -33)
    colorShaderDad:send("hue", -32)
    colorShaderDad:send("contrast", -23)

    getBoyfriend().shader = colorShaderBF
    getGirlfriend().shader = colorShaderGF
    getEnemy().shader = colorShaderDad
end
