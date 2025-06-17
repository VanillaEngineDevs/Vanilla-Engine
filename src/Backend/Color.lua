---@class Color
local Color = {}

---@param hex string|integer
---@return table<integer, integer, integer, integer>
function Color.hexToRgb(hex)
    if type(hex) == "string" then
        hex = hex:gsub("#", "")
        return {tonumber("0x" .. hex:sub(1, 2)) / 255, tonumber("0x" .. hex:sub(3, 4)) / 255, tonumber("0x" .. hex:sub(5, 6)) / 255, 1}
    elseif type(hex) == "number" then
        return {bit.rshift(hex, 16) / 255, bit.band(bit.rshift(hex, 8), 0xFF) / 255, bit.band(hex, 0xFF) / 255, 1}
    end

    return {1, 1, 1, 1}
end

---@param rgb table<integer, integer, integer>
---@return integer
function Color.rgbToHex(rgb)
    rgb[1] = rgb[1] or 0
    rgb[2] = rgb[2] or 0
    rgb[3] = rgb[3] or 0

    if #rgb == 3 then
        return bit.lshift(rgb[1], 16) + bit.lshift(rgb[2], 8) + rgb[3]
    elseif #rgb == 4 then
        return bit.lshift(rgb[1], 24) + bit.lshift(rgb[2], 16) + bit.lshift(rgb[3], 8) + rgb[4]
    end

    return 0x00000000
end

return Color