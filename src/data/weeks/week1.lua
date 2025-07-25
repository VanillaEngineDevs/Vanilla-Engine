local week = {}

week.meta = {
    name = "Week 1",
    desc = "DADDY DEAREST"
}

week.songs = {
    {
        name = "Tutorial",
        difficulties = nil, -- Defaults to easy, normal, hard
        hidden = false, -- Doesn't show up in the song select screen
        instrumentals = { -- All the different instrumentals
                          -- Good for the freeplay menu if freeplay inst is enabled!
            ["default"] = "songs/tutorial/Inst.ogg"
        }
    }
}

return week