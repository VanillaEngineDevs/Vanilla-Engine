--[[
-- reference
typedef StageFile = {
	var directory:String;
	var defaultZoom:Float;
	var isPixelStage:Bool;
	var stageUI:String;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
	var hide_girlfriend:Bool;

	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_girlfriend:Array<Float>;
	var camera_speed:Null<Float>;
}
]]

local StageData = Object:extend()

function StageData:dummy()
    return {
        directory = "",
        defaultZoom = 0.9,
        isPixelStage = false,
        stageUI = "normal",

        boyfriend = {770, 100},
        girlfriend = {400, 130},
        opponent = {100, 100},
        hide_girlfriend = false,

        camera_boyfriend = {0, 0},
        camera_opponent = {0, 0},
        camera_girlfriend = {0, 0},
        camera_speed = 1
    }
end

StageData.forceNextDirectory = nil

function StageData:loadDirectory(SONG)
    local stage = ""
    if SONG.stage then
        stage = SONG.stage
    elseif SONG.song then
        local songname = SONG.song:lower():gsub(" ", "-")

        if songname == "spookeez" or songname == "south" or songname == "monster" then
            stage = "spooky"
        elseif songname == "pico" or songname == "blammed" or songname == "philly" or songname == "philly-nice" then
            stage = "philly"
        elseif songname == "milf" or songname == "satin-panties" or songname == "high" then
            stage = "limo"
        elseif songname == "cocoa" or songname == "eggnog" then
            stage = "mall"
        elseif songname == "winter-horrorland" then
            stage = "mallEvil"
        elseif songname == "senpai" or songname == "roses" then
            stage = "school"
        elseif songname == "thorns" then
            stage = "schoolEvil"
        elseif songname == "ugh" or songname == "guns" or songname == "stress" then
            stage = "tank"
        else
            stage = "stage"
        end
    else
        stage = "stage"
    end

    local stageFile = self:getStageFile(stage)
    if not stageFile then
        self.forceNextDirectory = ""
    else
        self.forceNextDirectory = stageFile.directory
    end
end

function StageData:getStageFile(stage)
    local rawJson = nil
    local path = "assets/stages/" .. stage .. ".json"
    if love.filesystem.getInfo(path) then
        rawJson = json.decode(love.filesystem.read(path))
    else
        return nil
    end
    return rawJson
end

function StageData:vanillaSongStage(songName)
    if songName then
        if songName == "spookeez" or songName == "south" or songName == "monster" then
            return "spooky"
        elseif songName == "pico" or songName == "blammed" or songName == "philly" or songName == "philly-nice" then
            return "philly"
        elseif songNmae == "milf" or songName == "satin-panties" or songname == "high" then
            return "limo"
        elseif songname == "cocoa" or songname == "eggnog" then
            return "mall"
        elseif songname == "winter-horrorland" then
            return "mallEvil"
        elseif songname == "senpai" or songname == "roses" then
            return "school"
        elseif songname == "thorns" then
            return "schoolEvil"
        elseif songname == "ugh" or songname == "guns" or songname == "stress" then
            return "tank"
        end
    end
    return "stage"
end

return StageData