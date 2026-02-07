local hapticUtil = {}
hapticUtil.activeTweens = {}

local sdlHaptics = nil
pcall(function()
    sdlHaptics = require("game.modules.SDLHaptics")
    sdlHaptics.init()
end)

local Constants = {
    DEFAULT_VIBRATION_PERIOD = 0.1,
    DEFAULT_VIBRATION_DURATION = 0.5,
    DEFAULT_VIBRATION_AMPLITUDE = 0.5,
    DEFAULT_VIBRATION_SHARPNESS = 0.5,
    MAX_VIBRATION_AMPLITUDE = 1.0
}

Preferences = Preferences or {
    hapticsMode = 2, -- ALL
    hapticsIntensityMultiplier = 1
}

HAPTICS_MODE = {
    NONE = 0,
    NOTES_ONLY = 1,
    ALL = 2
}

hapticUtil.amplitudeTween = nil

hapticUtil.defaultVibrationPreset = {
    period = Constants.DEFAULT_VIBRATION_PERIOD,
    duration = Constants.DEFAULT_VIBRATION_DURATION,
    amplitude = Constants.DEFAULT_VIBRATION_AMPLITUDE,
    sharpness = Constants.DEFAULT_VIBRATION_SHARPNESS
}

function hapticUtil:isHapticsAvailable()
    if Preferences.hapticsMode == HAPTICS_MODE.NONE then
        return false
    end

    local os = love.system.getOS()
    if os == "Android" or os == "iOS" then
        return true
    end

    if sdlHaptics then
        return true
    end

    for _, js in ipairs(love.joystick.getJoysticks()) do
        if js:isGamepad() and js:isVibrationSupported() then
            return true
        end
    end

    return false
end

function hapticUtil:vibrate(period, duration, amplitude, sharpness, targetModes)
    period = period or Constants.DEFAULT_VIBRATION_PERIOD
    duration = duration or Constants.DEFAULT_VIBRATION_DURATION
    amplitude = amplitude or Constants.DEFAULT_VIBRATION_AMPLITUDE
    sharpness = sharpness or Constants.DEFAULT_VIBRATION_SHARPNESS

    if not self:isHapticsAvailable() then return end

    targetModes = targetModes or { HAPTICS_MODE.ALL }

    local allowed = false
    for _, mode in ipairs(targetModes) do
        if mode == Preferences.hapticsMode then
            allowed = true
            break
        end
    end
    if not allowed then return end

    local amp = math.min(
        amplitude * Preferences.hapticsIntensityMultiplier,
        Constants.MAX_VIBRATION_AMPLITUDE
    )

    if period > 0 then
        local step = period / 2
        local time = 0

        while time < duration do
            self:_vibrateOnce(step, amp)
            time = time + step
        end
    else
        self:_vibrateOnce(duration, amp)
    end
end

function hapticUtil:_vibrateOnce(duration, amplitude)
    if sdlHaptics then
        sdlHaptics.rumble(amplitude, duration)
    end

    for _, js in ipairs(love.joystick.getJoysticks()) do
        if js:isGamepad() and js:isVibrationSupported() then
            js:setVibration(amplitude, amplitude, duration)
        end
    end
end

function hapticUtil:vibrateByPreset(preset)
    preset = preset or self.defaultVibrationPreset
    self:vibrate(
        preset.period,
        preset.duration,
        preset.amplitude,
        preset.sharpness
    )
end

function hapticUtil:increasingVibrate(startAmp, targetAmp, tweenDuration)
    tweenDuration = tweenDuration or 1

    if self.amplitudeTween then
        self.amplitudeTween.cancelled = true
    end

    local tween = {
        time = 0,
        duration = tweenDuration,
        startAmp = startAmp,
        targetAmp = targetAmp,
        cancelled = false,
        finished = false
    }

    self.amplitudeTween = tween
    table.insert(self.activeTweens, tween)
end

function hapticUtil:update(dt)
    for i = #self.activeTweens, 1, -1 do
        local tween = self.activeTweens[i]

        if tween.cancelled then
            table.remove(self.activeTweens, i)
        else
            tween.time = tween.time + dt
            local t = math.min(tween.time / tween.duration, 1)

            local currentAmp =
                tween.startAmp +
                (tween.targetAmp - tween.startAmp) * t

            self:vibrate(
                0,
                Constants.DEFAULT_VIBRATION_DURATION / 10,
                currentAmp
            )

            if t >= 1 then
                self:vibrate(
                    Constants.DEFAULT_VIBRATION_PERIOD,
                    Constants.DEFAULT_VIBRATION_DURATION,
                    tween.targetAmp * 2
                )

                table.remove(self.activeTweens, i)
            end
        end
    end
end

return hapticUtil
