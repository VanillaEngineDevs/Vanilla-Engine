local SpriteGroup = Sprite:extend()

function SpriteGroup:new(x, y, maxSize)
    self:initGroup(maxSize)
    Sprite.new(self, x, y)
end

function SpriteGroup:initGroup(maxSize)
    self.group = Group(maxSize)
end

function SpriteGroup:destroy()
    self.group:destroy()
    Sprite.destroy(self)
end

function SpriteGroup:clone()
    local newGroup = SpriteGroup(self.x, self.y, self.group.maxSize)
    for _, sprite in ipairs(self.group.members) do
        if sprite ~= nil then
            newGroup:add(sprite:clone())
        end
    end
    return newGroup
end

function SpriteGroup:isOnScreen(camera)
    for _, sprite in ipairs(self.group.members) do
        if sprite ~= nil and sprite.exists and sprite.visible and sprite:isOnScreen(camera) then
            return true
        end
    end
    return false
end

function SpriteGroup:overlapsPoint(point, InScreenSpace, Camera)
    local result = false
    for _, sprite in ipairs(self.group.members) do
        if sprite ~= nil and sprite.exists and sprite.visible then
            result = result or sprite:overlapsPoint(point, InScreenSpace, Camera)
        end
    end
    return result
end

--[[
{
		var result:Bool = false;
		for (sprite in group.members)
		{
			if (sprite != null && sprite.exists && sprite.visible)
			{
				result = result || sprite.pixelsOverlapPoint(point, Mask, Camera);
			}
		}

		return result;
	}

	override public function update(elapsed:Float):Void
	{
		group.update(elapsed);

		if (path != null && path.active)
			path.update(elapsed);

		if (moves)
			updateMotion(elapsed);
	}]]

function SpriteGroup:update(dt)
    self.group:update(dt)

    if self.path and self.path.active then
        self.path:update(dt)
    end

    --[[ if self.moves then
        self:updateMotion(dt)
    end ]]
end

function SpriteGroup:draw(forcedCamera)
    if not forcedCamera then
        if #self.cameras <= 0 then
            self:render(Camera._defaultCameras[1])
        end
        for _, camera in ipairs(self.cameras) do
            self:render(camera)
        end
    else
        self:render(forcedCamera)
    end
end

function SpriteGroup:render(camera)
    love.graphics.push()
    camera:applyTransform()
    love.graphics.translate(self.x, self.y)
    love.graphics.translate(-Game.width / 2, -Game.height / 2)
    love.graphics.rotate(math.rad(self.angle))
    love.graphics.scale(self.scale.y or 1, self.scale.y or 1)
    love.graphics.translate(Game.width / 2, Game.height / 2)

    for _, sprite in ipairs(self.group.members) do
        if sprite ~= nil and sprite.exists and sprite.visible then
            sprite:draw()
        end
    end
    love.graphics.pop()
end

function SpriteGroup:add(sprite)
    self:preAdd(sprite)
    return self.group:add(sprite)
end

function SpriteGroup:insert(pos, sprite)
    self:preAdd(sprite)
    return self.group:insert(pos, sprite)
end

function SpriteGroup:preAdd(sprite)
    sprite.alpha = sprite.alpha * self.alpha
    sprite.scrollFactor = table.copy(self.scrollFactor or {})
    sprite.cameras = table.copy(self.cameras or {})
end

function SpriteGroup:move(x, y)
    self.x = self.x + x
    self.y = self.y + y
end

function SpriteGroup:setPosition(x, y)
    self.x = x
    self.y = y
end

function SpriteGroup:recycle(spriteClass, factory, force)
    return self.group:recycle(spriteClass, factory, force)
end

function SpriteGroup:remove(sprite, splice)
    sprite.cameras = {}
    return self.group:remove(sprite, splice)
end

function SpriteGroup:replace(old, new)
    self:preAdd(new)
    return self.group:replace(old, new)
end

function SpriteGroup:getFirstAvailable(spriteClass)
    return self.group:getFirstAvailable(spriteClass)
end

function SpriteGroup:sort(func, order)
    return self.group:sort(func, order)
end

function SpriteGroup:refresh()
    return self.group:refresh()
end

function SpriteGroup:getObjects()
    return self.group:getObjects()
end

function SpriteGroup:clear()
    self.group:clear()
end

return SpriteGroup