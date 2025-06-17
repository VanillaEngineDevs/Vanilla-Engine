---@class Constants
Constants = {}

Constants.TITLE = "Friday Night Funkin'"
Constants.VERSION_SUFFFIX = Config.Debug and " PROTOTYPE" or ""
Constants.VERSION = "0.4.1"
Constants.GENERATED_BY = Constants.TITLE .. " - " .. Constants.VERSION

Constants.URL_MERCH = "https://needlejuicerecords.com/pages/friday-night-funkin"
Constants.URL_ITCH = "https://ninja-muffin24.itch.io/funkin/purchase"
Constants.URL_KICKSTARTER = "https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game/"

Constants.COLOR_HEALTH_BAR_RED = 0xFFFFF0000
Constants.COLOR_HEALTH_BAR_GREEN = 0xFF66FF33

Constants.COLOR_NOTES ={
    0xFFFF22AA, -- left
    0xFF00EEFF, -- down
    0xFF00CC00, -- up
    0xFFCC1111  -- right
}

Constants.DEFAULT_DIFFICULTY = "normal"
Constants.DEFAULT_DIFFICULTY_LIST = {"easy, normal, hard"}
Constants.DEFAULT_DIFFICULTY_LIST_FULL = {"easy", "normal", "hard", "erect", "nightmare"}

Constants.DEFAULT_CHARACTER = "bf"
Constants.DEFAULT_HEALTH_ICON = "face"
Constants.DEFAULT_STAGE = "mainStage"
Constants.DEFAULT_SONG = "tutorial"
Constants.DEFAULT_VARIATION = "default"
Constants.DEFAULT_VARIATION_LIST = {"default", "erect", "pico"}

Constants.DEFAULT_BOP_INTENSITY = 1.015
Constants.DEFAULT_ZOOM_RATE = 4

Constants.DEFAULT_BPM = 100

Constants.DEFAULT_SONGNAME = "Unknown"
Constants.DEFAULT_ARTIST = "Unknown"
Constants.DEFAULT_NOTE_STYLE =  "funkin"
Constants.DEFAULT_ALBUM_ID = "volume1"

Constants.DEFAULT_TIMEFORMAT = "ms"
Constants.DEFAULT_SCROLLSPEED = 1
Constants.DEFAULT_TIME_SIGNATURE_NUM = 4
Constants.DEFAULT_TIME_SIGNATURE_DEN = 4

Constants.PIXELS_PER_MS = 0.45
Constants.HIT_WINDOW_MS = 160

Constants.SECS_PER_MIN =  60
Constants.MS_PER_SEC = 1000
Constants.US_PER_MS = 1000

Constants.US_PER_SEC = Constants.US_PER_MS * Constants.MS_PER_SEC

Constants.NS_PER_US = 1000
Constants.NS_PER_MS = Constants.NS_PER_US * Constants.US_PER_MS
Constants.NS_PER_SEC = Constants.NS_PER_US * Constants.US_PER_MS * Constants.MS_PER_SEC

Constants.NOTIFICATION_DISMISS_TIME = 5 * Constants.MS_PER_SEC
Constants.STEPS_PER_BEAT = 4

Constants.MP3_DELAY_MS = 528 / 44100 * Constants.MS_PER_SEC

Constants.HEALTH_MAX = 2
Constants.HEALTH_STARTING = Constants.HEALTH_MAX / 2
Constants.HEALTH_MIN = 0
Constants.HEALTH_KILLER_BONUS = 2 / 100 * Constants.HEALTH_MAX
Constants.HEALTH_SICK_BONUS = 1.5 / 100 * Constants.HEALTH_MAX
Constants.HEALTH_GOOD_BONUS = 0.75 / 100 * Constants.HEALTH_MAX
Constants.HEALTH_BAD_BONUS = 0 / 100 * Constants.HEALTH_MAX
Constants.HEALTH_SHIT_BONUS = -1 / 100 * Constants.HEALTH_MAX

Constants.HEALTH_HOLD_BONUS_PER_SECOND = 7.5 / 100 * Constants.HEALTH_MAX
Constants.HEALTH_MISS_PENALTY = 4 / 100 * Constants.HEALTH_MAX
Constants.HEALTH_GHOST_MISS_PENALTY = 2 / 100 * Constants.HEALTH_MAX

Constants.HEALTH_HOLD_DROP_PENALTY = 0
Constants.HEALTH_MINE_PENALTY = 15 / 100 * Constants.HEALTH_MAX

Constants.SCORE_HOLD_BONUS_PER_SECOND = 250

Constants.JUDGEMENT_KILLER_COMBO_BREAK = false
Constants.JUDGEMENT_SICK_COMBO_BREAK = false
Constants.JUDDGEMENT_GOOD_COMBO_BREAK = false
Constants.JUDGEMENT_BAD_COMBO_BREAK = true
Constants.JUDGEMENT_SHIT_COMBO_BREAK = true

Constants.EXT_CHART = "fnfc"
Constants.EXT_SOUND = "ogg"
Constants.EXT_VIDEO = "mp4"
Constants.EXT_IMAGE = "png"
Constants.EXT_DATA = "json"

Constants.GHOST_TAPPING = false

Constants.PIXEL_ART_SCALE = 6
Constants.COUNTDOWN_VOLUME = 0.6

Constants.STRUMLINE_X_OFFSET = 48

Constants.STRUMLINE_Y_OFFSET = 24*4

Constants.DDEFAULT_CAMERA_FOLLOW_RATE = 0.04

return Constants