-- String functions

function string.startsWith(self, str)
    return self:sub(1, #str) == str
end

function string.endsWith(self, str)
    return self:sub(-#str) == str
end

-- Math functions
function math.round(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end