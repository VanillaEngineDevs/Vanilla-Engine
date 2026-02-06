function Character:onCreate()
    self.data.danceEvery = 0
    self.data:play("idle", true, false)

    gameoverSubstate.musicSuffix = "-pico"
    gameoverSubstate.blueBallSuffix = "-pico-gutpunch"
end

local cantUppercut = false

function Character:onNoteHit(event)
    self.data.holdTimer = 0
    if not event.noteType:startsWith("weekend-1-") then return end

    local shouldDoUppercutPrep = self:wasNoteHitPoorly(event) and self:isPlayerLowHealth() and self:isDarnellPreppingUppercut()

    if shouldDoUppercutPrep then
        self:playPunchHighAnim()
        return
    end

    if cantUppercut then
        self:playBlockAnim()
        cantUppercut = false
        return
    end

    if event.noteType == "weekend-1-punchlow" or event.noteType == "weekend-1-punchlowblocked" or event.noteType == "weekend-1-punchlowdodged" or event.noteType == "weekend-1-punchlowspin" then
        self:playPunchLowAnim()
    elseif event.noteType == "weekend-1-punchhigh" or event.noteType == "weekend-1-punchhighblocked" or event.noteType == "weekend-1-punchhighdodged" or event.noteType == "weekend-1-punchhighspin" then
        self:playPunchHighAnim()
    elseif event.noteType == "weekend-1-blockhigh" or event.noteType == "weekend-1-blocklow" or event.noteType == "weekend-1-blockspin" then
        self:playBlockAnim()
    elseif event.noteType == "weekend-1-dodgehigh" or event.noteType == "weekend-1-dodgelow" or event.noteType == "weekend-1-dodgespin" then
        self:playDodgeAnim()
    elseif event.noteType == "weekend-1-hithigh" then
        self:playHitHighAnim()
    elseif event.noteType == "weekend-1-hitlow" then
        self:playHitLowAnim()
    elseif event.noteType == "weekend-1-hitspin" then
        self:playHitSpinAnim()
    elseif event.noteType == "weekend-1-picouppercutprep" then
        self:playUppercutPrepAnim()
    elseif event.noteType == "weekend-1-picouppercut" then
        self:playUppercutAnim(true)
    elseif event.noteType == "weekend-1-darnelluppercutprep" then
        self:playIdleAnim()
    elseif event.noteType == "weekend-1-darnelluppercut" then
        self:playUppercutHitAnim()
    elseif event.noteType == "weekend-1-idle" then
        self:playIdleAnim()
    elseif event.noteType == "weekend-1-fakeout" then
        self:playFakeoutAnim()
    elseif event.noteType == "weekend-1-taunt" then
        self:playTauntConditionalAnim()
    elseif event.noteType == "weekend-1-tauntforce" then
        self:playTauntAnim()
    elseif event.noteType == "weekend-1-reversefakeout" then
        self:playIdleAnim()
    end
end

function Character:play(name, force, loop)
    if name == "firstDeath" then
        Timer.after(1.25, function() self:afterPicoDeathGutPunchIntro() end)

        Timer.after(0.5, function()
            hapticUtil:vibrate(0, 0.1, 0.1, 1)

            Timer.after(0.6, function()
                hapticUtil:vibrate(0, 0.1, 0.1, 1)
            end)
        end)
    end

    self.data:play(name, force, loop)
end

function Character:afterPicoDeathGutPunchIntro()
    gameoverSubstate:startDeathMusic(1, false)
    self.data:play("deathLoop", true, false)
end

function Character:onNoteMiss(event)
    self.data.holdTimer = 0

    if self:isDarnellInUppercut() then
        self:playUppercutHitAnim()
        return
    end

    if self:willMissBeLethal(event) then
        self:playHitLowAnim()
        return
    end

    if cantUppercut then
        self:playHitHighAnim()
        return
    end

    if event.noteType == "weekend-1-punchlow" or event.noteType == "weekend-1-punchlowblocked" or event.noteType == "weekend-1-punchlowdodged" then
        self:playHitLowAnim()
    elseif event.noteType == "weekend-1-punchlowspin" then
        self:playHitSpinAnim()
    elseif event.noteType == "weekend-1-punchhigh" or event.noteType == "weekend-1-punchhighblocked" or event.noteType == "weekend-1-punchhighdodged" then
        self:playHitHighAnim()
    elseif event.noteType == "weekend-1-punchhighspin" then
        self:playHitSpinAnim()
    elseif event.noteType == "weekend-1-blockhigh" then
        self:playHitHighAnim()
    elseif event.noteType == "weekend-1-blocklow" then
        self:playHitLowAnim()
    elseif event.noteType == "weekend-1-blockspin" then
        self:playHitSpinAnim()
    elseif event.noteType == "weekend-1-dodgehigh" then
        self:playHitHighAnim()
    elseif event.noteType == "weekend-1-dodgelow" then
        self:playHitLowAnim()
    elseif event.noteType == "weekend-1-dodgespin" then
        self:playHitSpinAnim()
    elseif event.noteType == "weekend-1-hithigh" then
        self:playHitHighAnim()
    elseif event.noteType == "weekend-1-hitlow" then
        self:playHitLowAnim()
    elseif event.noteType == "weekend-1-hitspin" then
        self:playHitSpinAnim()
    elseif event.noteType == "weekend-1-picouppercutprep" then
        self:playPunchHighAnim()
        cantUppercut = true
    elseif event.noteType == "weekend-1-picouppercut" then
        self:playUppercutAnim(false)
    elseif event.noteType == "weekend-1-darnelluppercutprep" then
        self:playIdleAnim()
    elseif event.noteType == "weekend-1-darnelluppercut" then
        self:playUppercutHitAnim()
    elseif event.noteType == "weekend-1-idle" then
        self:playIdleAnim()
    elseif event.noteType == "weekend-1-fakeout" then
        self:playHitHighAnim()
    elseif event.noteType == "weekend-1-taunt" then
        self:playTauntConditionalAnim()
    elseif event.noteType == "weekend-1-tauntforce" then
        self:playTauntAnim()
    elseif event.noteType == "weekend-1-reversefakeout" then
        self:playIdleAnim()
    end
end

function Character:willMissBeLethal(event)
    return weeks:getHealth() - event.healthChange <= 0
end

function Character:onNoteGhostMiss(event)
    -- gotta implement this first
    if self:willMissBeLethal(event) then
        self:playHitLowAnim()
    else
        self:playHitHighAnim()
    end
end

function Character:onSongRetry()
    cantUppercut = false
    self:playIdleAnim()

    gameoverSubstate.musicSuffix = "-pico"
    gameoverSubstate.blueBallSuffix = "-pico-gutpunch"
end

function Character:getDarnell()
    return weeks:getCharacter("enemy")
end

function Character:moveToBack()
    self.data.zIndex = 2000
    weeks:sort()
end

function Character:moveToFront()
    self.data.zIndex = 3000
    weeks:sort()
end

function Character:isDarnellPreppingUppercut()
    return self:getDarnell().sprite.curAnim == "uppercutPrep"
end

function Character:isDarnellInUppercut()
    return self:getDarnell().sprite.curAnim == "uppercut" or self:getDarnell().sprite.curAnim == "uppercut-hold"
end

function Character:wasNoteHitPoorly(event)
    return event.judgement == "bad" or event.judgement == "shit"
end

function Character:isPlayerLowHealth()
    return weeks:getHealth() <= 0.3 * 2
end

local alternate = false

function Character:doAlternate()
    alternate = not alternate
    return alternate and "1" or "2"
end

function Character:playBlockAnim()
    self.data:play("block", true, false)
    weeks:getCamera():shake(0.002, 0.1)
    self:moveToBack()
end

function Character:playCringeAnim()
    self.data:play("cringe", true, false)
    self:moveToBack()
end

function Character:playDodgeAnim()
    self.data:play("dodge", true, false)
    self:moveToBack()
end

function Character:playIdleAnim()
    self.data:play("idle", false, false)
    self:moveToBack()
end

function Character:playFakeoutAnim()
    self.data:play("fakeout", true, false)
    self:moveToBack()
end

function Character:playUppercutPrepAnim()
    self.data:play("uppercutPrep", true, false)
    self:moveToFront()
end

function Character:playUppercutAnim(hit)
    self.data:play("uppercut", true, false)
    if hit then
        weeks:getCamera():shake(0.005, 0.25)
    end
    self:moveToFront()
end

function Character:playUppercutHitAnim()
    self.data:play("uppercutHit", true, false)
    weeks:getCamera():shake(0.005, 0.25)
    self:moveToBack()
end

function Character:playHitHighAnim()
    self.data:play("hitHigh", true, false)
    weeks:getCamera():shake(0.0025, 0.15)
    self:moveToBack()
end

function Character:playHitLowAnim()
    self.data:play("hitLow", true, false)
    weeks:getCamera():shake(0.0025, 0.15)
    self:moveToBack()
end

function Character:playHitSpinAnim()
    self.data:play("hitSpin", true, false, true)
    weeks:getCamera():shake(0.0025, 0.15)
    self:moveToBack()
end

function Character:playPunchHighAnim()
    local postfix = self:doAlternate()
    self.data:play("punchHigh" .. postfix, true, false)
    self:moveToFront()
end

function Character:playPunchLowAnim()
    local postfix = self:doAlternate()
    self.data:play("punchLow" .. postfix, true, false)
    self:moveToFront()
end

function Character:playTauntConditionalAnim()
    if self.data.sprite.curAnim == "fakeout" then
        self:playTauntAnim()
    else
        self:playIdleAnim()
    end
end

function Character:playTauntAnim()
    self.data:play("taunt", true, false)
    self:moveToBack()
end
