local whos = {
    [0] = "boyfriend",
    [1] = "dad",
    [2] = "girlfriend"
}

function Event:on(t, v)
    local who = "boyfriend"
    if type(v.char) == "number" then
        who = whos[v.char]
    else
        who = v.char
    end

    local nameref = ""
    if who == "boyfriend" then
        nameref = "p2Icon"
    else
        nameref = "p1Icon"
    end
    local target = weeks.healthbar[nameref]

    local prevData = {
        x = target.x,
        y = target.y,
        scaleX = target.scaleX,
        scaleY = target.target,
        orientation = target.angle,
        offsetX = target.offsetX,
        offsetY = target.offsetY,
        shearX = target.shearX,
        shearY = target.shearY,
        scale = target.scale,
        scrollFactor = {target.scrollFactor[1], target.scrollFactor[2]},
        flipX = target.flipX,
        visible = target.visible,
        mostCommonColour = target.mostCommonColour
    }
    weeks.healthbar[nameref] = weeks.healthIconPreloads[v.id] or icon.newIcon(icon.imagePath(v.id), nil, true) or weeks.healthbar[nameref]
    for k, v in pairs(prevData) do
        weeks.healthbar[nameref][k] = v
    end
end
