local function onAnimationComplete(name)
    if name == "deathConfirm" then
        Character.data:play("deathConfirm-loop", true, true)
    elseif name == "laughEnd" then
        Character.data:play("laughEnd-loop", true, false)
    end
end

local function afterPicoDeathNeneIntro()
    Timer.after(1.5, function()
        if gameoverSubstate.hasPlayedDeathQuote then return end

        gameoverSubstate:playDeathQuote()
    end)
end

function Character:onCreate()
    gameoverSubstate.musicSuffix = "-pico"
    gameoverSubstate.blueBallSuffix = "-pico-and-nene"

    self.data.onAnimationFinished:connect(onAnimationComplete)
end

function Character:onSongRetry()
    gameoverSubstate.musicSuffix = "-pico"
    gameoverSubstate.blueBallSuffix = "-pico-and-nene"

    -- reset our position cuz my code is fucking GARBAGE
    self.data.x = self.data.x + 150
    self.data.y = self.data.y + 150
end

function Character:getDeathQuote()
    local dadID = enemy and enemy._data and enemy.id or "dad"

    if dadID == "tankman" then
        return "assets/week7/sounds/jeffGameover-pico/jeffGameover-" .. love.math.random(1, 10) .. ".ogg"
    else
        return nil
    end
end

function Character:play(name, force, loop)
    if name == "firstDeath" then
        self.data.x = self.data.x - 150
        self.data.y = self.data.y - 150
        Timer.after(0.58, afterPicoDeathNeneIntro)
    end

    self.data:play(name, force, loop)
end