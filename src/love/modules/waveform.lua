-- https://github.com/ThatRozebudDude/FPS-Plus-Public/blob/a43c39438536d4fc150c1e269fe49950e3b00754/source/WaveformSprite.hx

-- Usage example VVV
--[[ testWaveform = waveform(280, -300, 720, 1280, love.sound.newSoundData("music/menu/menu.ogg"))
	testWaveform.angle = math.rad(-90)
	testWaveform.drawStep = 8
	testWaveform.drawNegativeSpace = 4
	testWaveform.framerate = 24
	testWaveform.sampleLength = 0.5
	testWaveform:playAudio() 
]]

local waveform = Object:extend()
local ffi = require("ffi")

waveform.sound = nil
waveform.soundData = nil
waveform.color = {1, 1, 1}
waveform.sampleLength = 0.5
waveform.drawStep = 1
waveform.drawNegativeSpace = 0
waveform.multiply = 1

waveform.framerate = 60
waveform.frameTime = 0

function waveform:new(x, y, width, height, soundData)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.soundData = soundData
    self.sound = love.audio.newSource(soundData)

    self.color = {1, 1, 1}
    self.sampleLength = 0.5
    self.drawStep = 1
    self.drawNegativeSpace = 0
    self.multiply = 1

    self.framerate = 60
    self.frameTime = 0
    self.active = true

    self.angle = 0

    self.waveformPrinted = true
    self.wavData = {
        {{0}, {0}}, 
        {{0}, {0}}
    }
    self.rects = {}
end

function waveform:update(dt)
    if self.active and self.sound:isPlaying() then
        if self.frameTime >= 1 / self.framerate then
            self:updateWaveform()
            self.frameTime = 0
        else
            self.frameTime = self.frameTime + dt
        end
    end
end


--function waveformData(buffer:AudioBuffer, bytes:Bytes, time:Float, endTime:Float, multiply:Float = 1, ?array:Array<Array<Array<Float>>>, ?steps:Float):Array<Array<Array<Float>>>
local function waveformData(buffer, bytes, time, endTime, multiply, array, steps)
    -- convert above haxe code to lua
    if buffer == nil then
        return {
            {{0}, {0}},
            {{0}, {0}}
        }
    end

    local khz = buffer:getSampleRate() / 1000
    local channels = buffer:getChannelCount()

    local index = math.floor(time * khz)

    local samples = (endTime - time) * khz

    if steps == nil then
        steps = 1280
    end

    local samplesPerRow = samples / steps
    local samplesPerRowI = math.floor(samplesPerRow)

    local gotIndex = 0

    local lmin = 0
    local lmax = 0

    local rmin = 0
    local rmax = 0

    local rows = 0

    local simpleSample = true
    local v1 = false

    if array == nil then
        array = {
            {{0}, {0}},
            {{0}, {0}}
        }
    end

    while index < (bytes - 1) do
        if index >= 0 then
            --[[ local byte = buffer:getFFIPointer()[(index * channels * 2) + 1] ]]
            local byte = ffi.cast("uint16_t*", buffer:getFFIPointer())[index * channels * 2 + 1]

            if byte > 65535 / 2 then
                byte = byte - 65535
            end

            local sample = byte / 65535

            if sample > 0 then
                if sample > lmax then
                    lmax = sample
                end
            elseif sample < 0 then
                if sample < lmin then
                    lmin = sample
                end
            end

            if channels >= 2 then
                byte = ffi.cast("uint16_t*", buffer:getFFIPointer())[index * channels * 2 + 2]


                if byte > 65535 / 2 then
                    byte = byte - 65535
                end

                sample = byte / 65535

                if sample > 0 then
                    if sample > rmax then
                        rmax = sample
                    end
                elseif sample < 0 then
                    if sample < rmin then
                        rmin = sample
                    end
                end
            end
        end

        v1 = samplesPerRowI > 0 and (index % samplesPerRowI == 0) or false
        while simpleSample and v1 or rows >= samplesPerRow do
            v1 = false
            rows = rows - samplesPerRow

            gotIndex = gotIndex + 1

            local lRMin = math.abs(lmin) * multiply
            local lRMax = lmax * multiply

            local rRMin = math.abs(rmin) * multiply
            local rRMax = rmax * multiply

            if gotIndex > #array[1][1] then
                table.insert(array[1][1], lRMin)
            else
                array[1][1][gotIndex] = array[1][1][gotIndex] + lRMin
            end

            if gotIndex > #array[1][2] then
                table.insert(array[1][2], lRMax)
            else
                array[1][2][gotIndex] = array[1][2][gotIndex] + lRMax
            end

            if channels >= 2 then
                if gotIndex > #array[2][1] then
                    table.insert(array[2][1], rRMin)
                else
                    array[2][1][gotIndex] = array[2][1][gotIndex] + rRMin
                end

                if gotIndex > #array[2][2] then
                    table.insert(array[2][2], rRMax)
                else
                    array[2][2][gotIndex] = array[2][2][gotIndex] + rRMax
                end
            else
                if gotIndex > #array[2][1] then
                    table.insert(array[2][1], lRMin)
                else
                    array[2][1][gotIndex] = array[2][1][gotIndex] + lRMin
                end

                if gotIndex > #array[2][2] then
                    table.insert(array[2][2], lRMax)
                else
                    array[2][2][gotIndex] = array[2][2][gotIndex] + lRMax
                end
            end

            lmin = 0
            lmax = 0

            rmin = 0
            rmax = 0
        end

        index = index + 1
        rows = rows + 1
        if gotIndex > steps then
            break
        end
    end

    return array
end

function waveform:playAudio()
    self.sound:play()
end

function waveform:stopAudio()
    self.sound:stop()
end

function waveform:updateWaveform()
    self.wavData[1][1] = {}
    self.wavData[1][2] = {}
    self.wavData[2][1] = {}
    self.wavData[2][2] = {}

    local st = self.sound:tell("seconds") * 1000
    local et = st + 1000 * self.sampleLength

    local bytes = self.soundData:getSampleCount() * self.soundData:getChannelCount()

    self.wavData = waveformData(self.soundData, bytes, st, et, self.multiply, self.wavData, self.height)

    local gSize = self.width
    local hSize = gSize/2


    local lMin = 0
    local lMax = 0

    local rMin = 0
    local rMax = 0

    local leftLength = (
        #self.wavData[1][1] > #self.wavData[1][2] and #self.wavData[1][1] or #self.wavData[1][2]
    )

    local rightLength = (
        #self.wavData[2][1] > #self.wavData[2][2] and #self.wavData[2][1] or #self.wavData[2][2]
    )

    local length = leftLength > rightLength and leftLength or rightLength

    local index = 0
    for i = 1, length do
        index = i

        lmin = util.bound(((index < #self.wavData[1][1] and index >= 0) and self.wavData[1][1][index] or 0) * (gSize / 1.12), -hSize, hSize) / 2
        lmax = util.bound(((index < #self.wavData[1][2] and index >= 0) and self.wavData[1][2][index] or 0) * (gSize / 1.12), -hSize, hSize) / 2

        rmin = util.bound(((index < #self.wavData[2][1] and index >= 0) and self.wavData[2][1][index] or 0) * (gSize / 1.12), -hSize, hSize) / 2
        rmax = util.bound(((index < #self.wavData[2][2] and index >= 0) and self.wavData[2][2][index] or 0) * (gSize / 1.12), -hSize, hSize) / 2

        --pixels.fillRect(new Rectangle(hSize - (lmin + rmin), i * waveformDrawStep, (lmin + rmin) + (lmax + rmax), waveformDrawStep - waveformDrawNegativeSpace), waveformColor);
        if index > #self.rects then
            table.insert(self.rects, {
                {self.x + hSize - (lmin + rmin), self.y + i * self.drawStep, (lmin + rmin) + (lmax + rmax), self.drawStep - self.drawNegativeSpace},
                {self.x + hSize - (lmax + rmax), self.y + i * self.drawStep, (lmax + rmax) + (lmin + rmin), self.drawStep - self.drawNegativeSpace}
            })
        else
            self.rects[index] = {
                {self.x + hSize - (lmin + rmin), self.y + i * self.drawStep, (lmin + rmin) + (lmax + rmax), self.drawStep - self.drawNegativeSpace},
                {self.x + hSize - (lmax + rmax), self.y + i * self.drawStep, (lmax + rmax) + (lmin + rmin), self.drawStep - self.drawNegativeSpace}
            }
        end
    end
end

function waveform:draw()
    love.graphics.push()
    love.graphics.translate(self.x + self.width / 2, self.y + self.height / 2)
    love.graphics.rotate(self.angle)
    love.graphics.translate(-self.x - self.width / 2, -self.y - self.height / 2)
    if self.active then
        for i = 1, #self.rects do
            love.graphics.setColor(self.color)
            love.graphics.rectangle("fill", self.rects[i][1][1], self.rects[i][1][2], self.rects[i][1][3], self.rects[i][1][4])
            love.graphics.rectangle("fill", self.rects[i][2][1], self.rects[i][2][2], self.rects[i][2][3], self.rects[i][2][4])
        end
    end
    love.graphics.pop()
end

return waveform