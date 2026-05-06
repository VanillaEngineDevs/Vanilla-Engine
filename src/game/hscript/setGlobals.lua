local function setGlobals()
    function HScript.ctx.getNamedProp(name)
        return weeks:get(name)
    end

    HScript.main:setContext(HScript.ctx)
end

return setGlobals