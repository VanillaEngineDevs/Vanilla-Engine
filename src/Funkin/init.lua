local path = ...

local function r(p)
    return unpack {require(path .. "." .. p)}
end

Constants = r("util.Constants")
Paths = r("Paths")
Conductor = r("Conductor")

DataAssets = r("Util.Assets.DataAssets")

BaseRegistry = r("Data.BaseRegistry")
SongMetadata = r("Data.Song.SongData")
StageData = r("Data.Stage.StageData")
Song = r("Play.Song.Song")
VersionUtil = r("Util.VersionUtil")
SongRegistry = r("Data.Song.SongRegistry")()
StageRegistry = r("Data.Stage.StageRegistry")()
NoteStyleRegistry = r("Data.Notestyle.NoteStyleRegistry")()

SoundGroup = r("Audio.SoundGroup")
VoicesGroup = r("Audio.VoicesGroup")
FunkinSound = r("Audio.FunkinSound")

MenuTypedList = r("UI.MenuList")
AtlasMenuItem = r("UI.AtlasMenuList")

MusicBeatState = r("UI.MusicBeatState")

TitleState = r("UI.Title.TitleState")
MainMenuState = r("UI.MainMenu.MainMenuState")
PlayState = r("Play.PlayState")

FunkinSprite = r("Graphics.FunkinSprite")

NoteDirection = r("Play.Notes.NoteDirection")
Strumline = r("Play.Notes.Strumline")
StrumlineNote = r("Play.Notes.StrumlineNote")
NoteSprite = r("Play.Notes.NoteSprite")
NoteStyle = r("Play.Notes.Notestyle.NoteStyle")

r("Modding.Events.ScriptEvent")