local CoolUtil = {}

function CoolUtil.newGradient(dir, ...)
    local isHorizontal = true
    if dir == "vertical" then isHorizontal = false end

    local colorLen, meshData = select("#", ...), {}
    if isHorizontal then
        for i = 1, colorLen do
            local color = select(i, ...)
            local x = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {
                x, 1, x, 1, color[1], color[2], color[3], color[4] or 1
            }
            meshData[#meshData + 1] = {
                x, 0, x, 0, color[1], color[2], color[3], color[4] or 1
            }
        end
    else
        for i = 1, colorLen do
            local color = select(i, ...)
            local y = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {
                1, y, 1, y, color[1], color[2], color[3], color[4] or 1
            }
            meshData[#meshData + 1] = {
                0, y, 0, y, color[1], color[2], color[3], color[4] or 1
            }
        end
    end

    return love.graphics.newMesh(meshData, "strip", "static")
end

function CoolUtil.coolLerp(a, b, t, dt)
    local dt = dt or love.timer.getDelta()
    return math.lerp(a, b, 1 - 1 / math.exp(t * 60 * dt))
end

function CoolUtil.coolTextFile(file)
    local daList = nil
    local formatted = nil 
    if file:find(":") then
        formatted = file:split(":")[2]
    else
        formatted = {"", file}
    end

    if love.filesystem.getInfo(formatted[2]) then
        daList = CoolUtil.listFromString(love.filesystem.read(formatted[2]))
    end

    return daList
end

function CoolUtil.listFromString(string)
    local daList = {}
    daList = string:trim():split("\n")

    for i = 1, #daList do
        daList[i] = daList[i]:trim()
    end

    return daList
end

return CoolUtil