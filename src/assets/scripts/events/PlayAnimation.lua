function Event:on(t, v)
    if v.target == "bf" or v.target == "boyfriend" then
        for _, obj in ipairs(weeks.objects) do
            if obj.characterType == "bf" then
                obj:play(v.anim, v.force or false, false)
            end
        end
    elseif v.target == "gf" or v.target == "girlfriend" then
        for _, obj in ipairs(weeks.objects) do
            if obj.characterType == "gf" then
                obj:play(v.anim, v.force or false, false)
            end
        end
    elseif v.target == "dad" then
        for _, obj in ipairs(weeks.objects) do
            if obj.characterType == "dad" then
                obj:play(v.anim, v.force or false, false)
            end
        end
    end
end
