local fftSize = ...
local fft = require("lib.fft.luafft")
local inChannel = love.thread.getChannel("toFFT")
local util = require("modules.util")

local fftSizeInv = 1 / fftSize -- Because multiplication is slightly faster
local function postprocess(x)
    return x * fftSizeInv * 0.5 -- Normalization
end

while true do
    if inChannel:getCount() > 0 then
        -- Get input
        local toFFT = inChannel:pop()
        -- Perform FFT
        local res = {}
        util.tryExcept(
            function() 
                res = fft.fft(toFFT, false)

                -- Process the results to build an intuitive FFT result
                local fftArray = {}
                for i = 1, fftSize / 2 do
                    fftArray[i] = postprocess(res[i]:abs() + res[#res-i+1]:abs())
                end
                -- Send the result to the main thread
                love.thread.getChannel("fft"):push(fftArray)
            end,
            function(err) 
                love.thread.getChannel("fft"):push({}) 
            end
        )
    end
end