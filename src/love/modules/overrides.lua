---@diagnostic disable: duplicate-set-field
---@diagnostic disable: redundant-parameter, missing-parameter, inject-field
local threadEvent = love.thread.newThread("threads/eventThread.lua")

local channel_event = love.thread.getChannel("thread.event")
local channel_active = love.thread.getChannel("thread.event.active")


love._framerate = 165

love._currentFPS = 0
love._currentTPS = 0

love._drawDT = 0

local _
local _, _, flags = love.window.getMode()
love._framerate = flags.refreshrate or 60

function love.run()
    local love = love
    local arg = arg
    
    local g_origin, g_clear, g_present = love.graphics.origin, love.graphics.clear, love.graphics.present
    local g_active, g_getBGColour = love.graphics.isActive, love.graphics.getBackgroundColor
    local e_pump, e_poll, t = love.event.pump, love.event.poll, {}
    local t_step = love.timer.step
    local t_getTime = love.timer.getTime
    local a, b
    local dt = 0
    local love_load, love_update, love_draw = love.load, love.update, love.draw
    ---@diagnostic disable-next-line: undefined-field
    local love_quit, a_parseGameArguments = love.quit, love.arg.parseGameArguments
    local collectgarbage = collectgarbage
    ---@diagnostic disable-next-line: undefined-field
    local love_handlers = love.handlers
    local math = math
    local math_min, math_max = math.min, math.max
    local unpack = unpack

    local channel_active_clear = channel_active.clear
    local channel_active_push = channel_active.push
    local channel_event_pop = channel_event.pop
    local channel_event_demand = channel_event.demand

	love_load(a_parseGameArguments(arg), arg)

	t_step()
    t_step()
    collectgarbage()

    ---@diagnostic disable-next-line: redefined-local
    local function event(name, a, ...)
        if name == "quit" and not love_quit() then
            channel_active_clear(channel_active)
            channel_active_clear(channel_active)
            channel_active_push(channel_active, 0)

            return a or 0, ...
        end

        return love_handlers[name](a, ...)
    end

    local drawTmr = 999999
    local lastDraw = 0
    local draws = 0
    local fpsTimer = 0.0

	return function()
		if threadEvent:isRunning() then
            channel_active_clear(channel_active)
            channel_active_push(channel_active, 1)
            a = channel_event_pop()

            while a do
                b = channel_event_demand()
                for i =  1, b do
                    t[i] = channel_event_demand()
                end
                _, a, b = b, event(a, unpack(t, 1, b))
                if a then
                    e_pump()
                    return a, b
                end
                a = channel_event_pop()
            end
        end

        e_pump()

        ---@diagnostic disable-next-line: redefined-local
        for name, a, b, c, d, e, f in e_poll() do
           a, b = event(name, a, b, c, d, e, f)
           if a then return a, b end
        end

        local cap = love._framerate
        local capDT = 1 / cap

        -- Cap the minimum delta time to 1/30 (30 FPS)
        dt = math_min(t_step(), math_max(capDT, 1 / 30))

        love_update(dt)
        drawTmr = drawTmr + dt
        
        if drawTmr >= capDT then
            if g_active() then
                g_origin()
                g_clear(g_getBGColour())

                love_draw(love._drawDT or 0)

                g_present()

                love._drawDT = t_getTime() - lastDraw
                draws = draws + 1

                fpsTimer = fpsTimer + love._drawDT

                if fpsTimer > 1 then
                    love._currentFPS = draws
                    love._draws = draws
                    fpsTimer = fpsTimer % 1
                    draws = 0
                end
                lastDraw = t_getTime()
            end
            drawTmr = drawTmr % capDT
        end

        collectgarbage("step")
    end
end

local o_timer_getFPS = love.timer.getFPS
function love.timer.getFPS()
    return o_timer_getFPS()
end

function love.timer.getDrawFPS()
    -- use love._drawDT instead of love._currentFPS
    return love._currentFPS
end

function love.setFpsCap(fps)
    love._fps_cap = fps or 60
end

local curTranslate = {x = 0, y = 0}
local curScale = {x = 1, y = 1}

local o_graphics_translate = love.graphics.translate
local o_graphics_scale = love.graphics.scale

function love.graphics.translate(x, y)
    curTranslate.x = curTranslate.x + x
    curTranslate.y = curTranslate.y + y
    o_graphics_translate(x, y)
end

function love.graphics.scale(x, y)
    curScale.x = x
    curScale.y = y
    o_graphics_scale(x, y)
end

function love.graphics.getTranslate()
    return curTranslate.x, curTranslate.y
end

function love.graphics.getScale()
    return curScale.x, curScale.y
end