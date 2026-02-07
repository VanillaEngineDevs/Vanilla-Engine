local colorShader

local carSequence
local sequenceTime = 0
local sequenceStep = 0

local shader
local shaderCode = [[
extern float xPos;
extern float yPos;
extern float alphaShit;
extern Image funnyShit;

vec4 blendOverlay(vec4 base, vec4 blend) {
    vec4 mixed = mix(1.0 - 2.0 * (1.0 - base) * (1.0 - blend), 2.0 * base * blend, step(base, vec4(0.5)));

    // mixed = mix(mixed, blend, base.a); // proper alpha mixing?

    return mixed;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 baseCol = Texel(texture, texture_coords);
    vec2 funnyUV = texture_coords + vec2(0.1 + xPos, 0.2 + yPos);
    vec4 gf = Texel(funnyShit, funnyUV)

    vec4 mixedCol = blendOverlay(baseCol, gf);

    mixedCol.a *= alphaShit;

    return mixedCol * color;
}
]]

local doCarHaptics = false

local _timer = 0
local shootingStarBeat, shootingStarOffset = 0, 2
local fastCarCanDrive = false

function Stage:build()
   --[[  shader = love.graphics.newShader(shaderCode)
    local sunOverlay = graphics.newSparrowAtlas()
    sunOverlay:load(EXTEND_LIBRARY("week4:limo/limoOverlay"))
    sunOverlay.scale = {x = 2, y = 2}
    sunOverlay:updateHitbox()

    shader:send("funnyShit", sunOverlay.image) ]]
    -- ^ Damn I really thought that shit was used ngl

    colorShader = love.graphics.newShader("assets/shaders/adjustColor.glsl")

    colorShader:send("brightness", -23)
    colorShader:send("hue", 12)
    colorShader:send("contrast", 7)

    getBoyfriend().shader = colorShader
    getGirlfriend().shader = colorShader
    getEnemy().shader = colorShader

    colorShader:send("hue", -30)
    colorShader:send("saturation", -20)
    colorShader:send("contrast", 0)
    colorShader:send("brightness", -30)

    for i = 1, 5 do
        get("limoDancer"..i).shader = colorShader
    end
    get("fastCar").shader = colorShader

    carSequence = {
        {time = 1, callback = function() doCarHaptics = true end},
        {time = 1.4, callback = function() doCarHaptics = false end},
        {time = 2, callback = function() self:resetFastCar() end}
    }

    self:resetFastCar()
end

function Stage:onUpdate(dt)
    if doCarHaptics then hapticUtil:vibrate(0, 0.05, 0.25, 0) end

    if sequenceStep > 0 then
        sequenceTime = sequenceTime + dt

        while true do
            local step = carSequence[sequenceStep]
            if not step or sequenceTime < step.time then
                break
            end

            step.callback()
            sequenceStep = sequenceStep + 1
        end
    end

    local fastCar = get("fastCar")
    if fastCar then
        fastCar.x = fastCar.x + ((fastCar.velX or 0) * dt)
    end
end

local function randomBool(chance)
    return love.math.random() < (chance / 100)
end

function Stage:doShootingStar(beat)
    get("shootingStar").x = love.math.random(50, 900)
    get("shootingStar").y = love.math.random(-10, 20)
    get("shootingStar").flipX = randomBool(50)
    if get("shootingStar").flipX then
        get("shootingStar").x = get("shootingStar").x
    end
    get("shootingStar"):play("shooting star")

    shootingStarBeat = beat
    shootingStarOffset = love.math.random(4, 8)
end

function Stage:onBeatHit(beat)
    if randomBool(10) and fastCarCanDrive then
        self:fastCarDrive()
    end

    if randomBool(10) and beat > (shootingStarBeat + shootingStarOffset) then
        self:doShootingStar(beat)
    end
end

function Stage:resetFastCar()
    local fastCar = get("fastCar")
    if not fastCar then return end

    fastCar.x = -15000
    fastCar.y = love.math.random(140, 250)
    fastCarCanDrive = true
    fastCar.velX = 0
end

local carSound
function Stage:fastCarDrive()
    carSound = carSound or love.audio.newSource(EXTEND_LIBRARY_SFX("week4:carPass"..love.math.random(0,1)..".ogg", true), "stream")
    local fastCar = get("fastCar")
    fastCar.velX = 15000
    fastCarCanDrive = false

    sequenceStep = 1
    sequenceTime = 0
    --[[ carSound:play() ]]
    audio.playSound(carSound)
end

function Stage:onSongRetry()
    self:resetFastCar()
    shootingStarBeat = 0
    shootingStarOffset = 2
end

function Stage:onCountdownStart(event)
    self:resetFastCar()
end