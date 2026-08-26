function Level:isUnlocked()
    return true
end

function Level:getSongDisplayNames()
    if settings.getSavedata().hasBeatenLevel("weekend1") then
        return { "Darnell", "Lit Up", "2hot", "Blazin'" }
    else
        return { "Darnell", "Lit Up", "2hot" }
    end
end
