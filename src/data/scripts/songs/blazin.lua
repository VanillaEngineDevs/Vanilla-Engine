local hasHidden = false
local hasPlayedCutscene = false

function Song:onCreate()
    self.hasHidden = false
    self.hasPlayedCutscene = false
end

function Song:onUpdate(dt)
    if not hasHidden then
        hasHidden = true
        self:hideOpponentStrumline()
        self:centerPlayerStrumline()
    end
end

function Song:hideOpponentStrumline()
    for i = 1, #enemyArrows do
        enemyArrows[i].visible = false
        for j = 1, #enemyNotes[i] do
            enemyNotes[i][j].visible = false
        end
    end
end

function Song:centerPlayerStrumline()
    for i = 1, #boyfriendArrows do
        boyfriendArrows[i].x = -410 + 165 * i
        for j = 1, #boyfriendNotes[i] do
            boyfriendNotes[i][j].x = boyfriendArrows[i].x
        end
    end
end
