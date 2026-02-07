function Character:getAtlasSettings()
    return {
        onSymbolCreate = function(symbol)
            for _, layer in ipairs(symbol.layers) do
                if layer.name:startsWith("HAT") then
                    layer.visible = false
                end
            end
        end
    }
end
