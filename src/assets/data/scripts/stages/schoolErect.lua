local colorShader

function Stage:build()
    print(weeks:getSongName():lower():strip() == "roses")
    if weeks:getSongName():lower():strip() == "roses" then
        get("freaks"):setSuffix("-scared")
        print("Applied scared suffix to freaks character for Roses song.")
    else
        get("freaks"):setSuffix("")
    end
end

function Stage:addCharacter(char, name)
    colorShader = colorShader or love.graphics.newShader("assets/shaders/adjustColor.glsl")

    colorShader:send("brightness", -66)
    colorShader:send("hue", -10)
    colorShader:send("contrast", 24)
    colorShader:send("saturation", -23)

    char.shader = colorShader
end
