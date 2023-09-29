local SwagSong = Object:extend()
SwagSong.song = ""
SwagSong.notes = {}
SwagSong.events = {}
SwagSong.bpm = 0
SwagSong.needsVoices = true
SwagSong.speed = 1
SwagSong.player1 = ""
SwagSong.player2 = ""
SwagSong.gfVersion = ""
SwagSong.stage = ""

local Song = Object:extend()

Song.song = ""
Song.notes = {}
Song.events = {}
Song.bpm = 100
Song.needsVoices = true
Song.speed = 1
Song.stage = ""
Song.player1 = "bf"
Song.player2 = "dad"
Song.gfVersion = "gf"

function Song.onLoadJson(songJson)
    if not songJson.gfVersion then
        songJson.gfVersion = songJson.player3
        songJson.player3 = nil
    end

    if not songJson.events then
        songJson.events = {}

        for secNum = 1, #songJson.notes do
            local sec = songJson.notes[secNum]

            local i = 1
            local notes = sec.sectionNotes
            local len = #notes

            while i < len do
                local note = notes[i]
                if note[1] < 0 then
                    table.insert(songJson.events, {note[1], {note[3], note[4], note[5]}})
                    table.remove(notes, i)
                    len = #notes
                else
                    i = i + 1
                end
            end
        end
    end

    return songJson
end

function Song:new(song, notes, bpm)
    self.song = song
    self.notes = notes
    self.bpm = bpm
end

function Song:loadFromJson(jsonInput, folder)
    local rawJson = nil
    --local formattedSong = Paths.formatToSongPath(jsonInput)
    --print("Loading song " .. jsonInput)
    local formattedSong = Paths.formatToSongPath(jsonInput)
    local folder = Paths.formatToSongPath(folder)

    if not rawJson then
        if not jsonInput:find("events") then
            TryExcept(
                function()
                    --rawJson = love.filesystem.read("assets/data/" .. formattedSong)
                    -- check if file exists
                    print("assets/data/" .. folder .. "/" .. formattedSong .. ".json")
                    if love.filesystem.getInfo("assets/data/" .. folder .. "/" .. formattedSong .. ".json") then
                        rawJson = love.filesystem.read("assets/data/" .. folder .. "/" .. formattedSong .. ".json")
                    else
                        Break()
                    end
                end,
                function()
                    rawJson = love.filesystem.read("assets/data/" .. folder .. "/" .. formattedSong .. ".json")
                end
            )
        else
            rawJson = love.filesystem.read("assets/data/" .. formattedSong .. ".json")
        end
    end
    songJson = json.decode(rawJson)
    if self.jsonInput ~= "events" then
        -- bleh
    end
    songJson = Song.onLoadJson(songJson.song)
    return songJson
end

return Song