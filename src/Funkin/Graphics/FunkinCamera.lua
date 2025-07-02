local FunkinCamera = Camera:extend("FunkinCamera")

function FunkinCamera:new(id, x, y, w, h, zoom)
    Camera.new(self, x or 0, y or 0, w or Game.width, h or Game.height)
    self.zoom = zoom or 1

    self.id = id or "unknown"
end

return FunkinCamera