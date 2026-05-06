local cover = {}
cover.covers = {}
cover.spr = nil
cover.image = nil

function cover:setup()
    self.image = love.graphics.newImage(graphics.imagePath("holdCovers"))
    self.spr = love.filesystem.load("sprites/holdCover.lua")

    for i = 1, 2 do
        self.covers[i] = {}
        for j = 1, 4 do
            self.covers[i][j] = self.spr()
            self.covers[i][j].visible = false
            if i == 1 then
                self.covers[i][j].y = boyfriendArrows[j].y + 35
                self.covers[i][j].x = boyfriendArrows[j].x - 5
            else
                self.covers[i][j].y = enemyArrows[j].y + 35
                self.covers[i][j].x = enemyArrows[j].x - 5
            end
        end
    end
end

function cover:update(dt)
    for i = 1, 4 do
        if self.covers[1][i].visible then
            self.covers[1][i].x = boyfriendArrows[i].x - 5
            self.covers[1][i].y = boyfriendArrows[i].y + 35
            self.covers[1][i]:update(dt)
        end
        if self.covers[2][i].visible then
            self.covers[2][i].x = enemyArrows[i].x - 5
            self.covers[2][i].y = enemyArrows[i].y + 35
            self.covers[2][i]:update(dt)
        end
    end
end

function cover:getVisibility(id, plr)
    return self.covers[plr][id].hiding
end

-- 1 = boyfriend, 2 = enemy
function cover:show(id, plr)
    if not self.covers[plr][id].visible then
        self.covers[plr][id].hiding = false
        self.covers[plr][id].visible = true
        self.covers[plr][id]:animate(CONSTANTS.WEEKS.NOTE_LIST[id] .. " start", false, function()
            self.covers[plr][id]:animate(CONSTANTS.WEEKS.NOTE_LIST[id], true)
        end)
    end
end

function cover:hide(id, plr)
    self.covers[plr][id].hiding = true
    self.covers[plr][id]:animate(CONSTANTS.WEEKS.NOTE_LIST[id] .. " end", false, function()
        self.covers[plr][id].visible = false
    end)
end

function cover:draw()
    for i = 1, 4 do
        if self.covers[1][i].visible then
            self.covers[1][i]:draw()
        end
        if self.covers[2][i].visible then
            self.covers[2][i]:draw()
        end
    end
end

return cover