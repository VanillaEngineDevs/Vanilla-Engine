love._fps_cap = 60

love.run = love.system.getOS() ~= "NX" and function()
    if love.math then
        love.math.setRandomSeed(os.time())
    end

    if love.event then
        love.event.pump()
    end

    if love.load then love.load(arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0

    -- Main loop time.
    while true do
        local m1 = love.timer.getTime() -- measure the time at the beginning of the main iteration
        -- Process events.
        if love.event then
            love.event.pump()
            for e,a,b,c,d in love.event.poll() do
                if e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a,b,c,d)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        -- Call update and draw
        if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

        if love.window and love.graphics and love.window.isOpen() then
            love.graphics.clear()
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end
	    local delta1 = love.timer.getTime() - m1 -- measure the time at the end of the main iteration and calculate delta
        if love.timer then love.timer.sleep(1/love._fps_cap-delta1) end
    end
end or love.run

function love.setFpsCap(fps)
    love._fps_cap = fps or 60
end
