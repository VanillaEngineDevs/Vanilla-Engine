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
    return a + (b - a) * math.min(t * dt, 1)
end

return CoolUtil