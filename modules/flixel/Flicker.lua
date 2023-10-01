local Flicker = {}

Flicker.members = {}

function Flicker:flicker(obj, duration, interval, endVisibility, callback, progressCallback)
    if not obj then return end
    local new = {}
    new.obj = obj
    new.duration = duration or 1
    new.interval = interval or 1
    new.endVisibility = endVisibility or true
    new.callback = callback or function() end
    new.progressCallback = progressCallback or function() end

    new.flickTime = 0
    new.timer = 0

    table.insert(self.members, new)
end

function Flicker:update(dt)
    for i, member in ipairs(self.members) do
        member.timer = member.timer + dt

        if member.timer <= member.duration then
            member.flickTime = member.flickTime + dt
            if member.flickTime >= member.interval then
                member.obj.visible = not member.obj.visible
                member.flickTime = member.flickTime - member.interval
            end
        end

        if member.timer >= member.duration then
            member.obj.visible = member.endVisibility
            member.callback()
            table.remove(self.members, i)
        end
    end
end

return Flicker