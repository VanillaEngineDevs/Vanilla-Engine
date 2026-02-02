local signal = {}

function signal.new()
    local self = {}

    self._subscribers = {}

    function self:connect(func)
        table.insert(self._subscribers, func)
    end

    function self:disconnect(func)
        for i, f in ipairs(self._subscribers) do
            if f == func then
                table.remove(self._subscribers, i)
                break
            end
        end
    end

    function self:emit(...)
        for _, func in ipairs(self._subscribers) do
            func(...)
        end
    end

    return self
end

return signal