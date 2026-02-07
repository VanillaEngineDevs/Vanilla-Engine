local imageFormats = {}
local font

local padding = 12
local lineHeight = 18
local scrollY = 0

local panelX = 20
local panelY = 20
local panelWidth = 360
local panelHeight = love.graphics.getHeight() - 40

function love.load()
    font = love.graphics.newFont(14)
    love.graphics.setFont(font)

    for format, supported in pairs(love.graphics.getImageFormats()) do
        table.insert(imageFormats, {
            name = format,
            supported = supported
        })
    end

    table.sort(imageFormats, function(a, b)
        return a.name < b.name
    end)
end

function love.wheelmoved(_, y)
    scrollY = scrollY - -y * lineHeight * 2
end

function love.draw()
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight, 8, 8)

    love.graphics.setColor(1, 1, 1, 0.15)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight, 8, 8)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(
        "Supported Image Formats",
        panelX + padding,
        panelY + padding
    )

    local contentY = panelY + padding + lineHeight
    local contentHeight = panelHeight - padding * 2 - lineHeight

    love.graphics.setScissor(
        panelX,
        contentY,
        panelWidth,
        contentHeight
    )

    local drawY = contentY + scrollY

    for _, entry in ipairs(imageFormats) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(
            entry.name,
            panelX + padding,
            drawY
        )

        if entry.supported then
            love.graphics.setColor(0.4, 1.0, 0.4, 1)
            love.graphics.print(
                "Supported",
                panelX + panelWidth - padding - 80,
                drawY
            )
        else
            love.graphics.setColor(1.0, 0.4, 0.4, 1)
            love.graphics.print(
                "Unsupported",
                panelX + panelWidth - padding - 100,
                drawY
            )
        end

        drawY = drawY + lineHeight
    end

    love.graphics.setScissor()
    love.graphics.setColor(1, 1, 1, 1)
end

function love.update(dt)
    local totalHeight = #imageFormats * lineHeight
    local visibleHeight = panelHeight - padding * 2 - lineHeight

    local minScroll = math.min(0, visibleHeight - totalHeight)
    scrollY = math.max(minScroll, math.min(0, scrollY))
end
