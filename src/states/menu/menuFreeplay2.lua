local f = {}

f.FADE_IN_DURATION = 2
f.FADE_OUT_DURATION = 2
f.FADE_IN_START_VOLUME = 0
f.FADE_IN_END_VOLUME = 0.7
f.FADE_IN_DELAY = 0.25
f.FADE_OUT_END_VOLUME = 0

f.CUTOUT_WIDTH = 0 -- idunno

f.DJ_POS_MULTI = 0.44
f.SONGS_POS_MULTI = 0.75

function f:enter()
    self.songs = {}
    self.diffIdsCurrent = {}
    self.diffIdsTotal = { "easy", "normal", "hard" }
    self.curSelected = 1
    self.curSelectedFractal = 0
    self.currentDifficulty = "normal"

    --self.fp
    --self.txtCompletion
    self.lerpCompletion = 0
    self.intendedCompletion = 0
    self.lerpScore = 0
    self.intendedScore = 0

    self.grpDifficulties = Group()
    self.grpSongs = Group()
    self.grpCapsules = Group()
    
    --self.curCapsule

    self.backingImage = graphics.newSparrowAtlas()
end

return f