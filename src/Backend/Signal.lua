---@class Signal
local Signal = Class:extend()

function Signal:new()
    self.functions = {}

    --[[ print("Created Signal") ]]
end

unpack = unpack or table.unpack

---@param func function
function Signal:add(func, super)
    table.insert(self.functions, {func, super})
end

---@param func function
function Signal:remove(func)
    for i, f in ipairs(self.functions) do
        if f == func[1] then
            table.remove(self.functions, i)
            break
        end
    end
end

function Signal:dispatch()
    for _, func in ipairs(self.functions) do
        if func[1] then func[1](func[2]) end
    end
end

return Signal