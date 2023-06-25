savedata = {}

function loadSavedata()
    -- read savedata with lume
    if love.filesystem.getInfo("savedata") then
        savedata = lume.deserialize(love.filesystem.read("savedata"))
    else
        savedata = {}
    end
end

function saveSavedata()
    -- write savedata with lume
    love.filesystem.write("savedata", lume.serialize(savedata))
end