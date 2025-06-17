---@class Graphic
local Graphic = {}

Graphic.cache = {}

---@param graphicPath string
---@return love.Drawable
function Graphic:getGraphic(graphicPath)
    if self.cache[graphicPath] then
        return self.cache[graphicPath]
    end

    if love.filesystem.getInfo(graphicPath) then
        self.cache[graphicPath] = love.graphics.newImage(graphicPath)
    else
        print("File does not exist (" .. graphicPath .. ")")

        ---@diagnostic disable-next-line: missing-return-value -- Temp
        return --[[Graphic.defaultGraphic]] -- TODO: defaultGraphic
    end

    return self.cache[graphicPath]
end

return Graphic