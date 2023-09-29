local Stage = BaseStage:extend()

Stage.bgGhouls = nil

function Stage:create()
    local posX, posY = 875, 1050
    bg = BGSprite("stages/school/animatedEvilSchool", -posX, -posY, 0.8, 0.9, {"background 2"}, true)
    bg.scale = {x = PlayState.daPixelZoom, y = PlayState.daPixelZoom}
    self:add(bg)
    bg.antialiasing = false

    self:setDefaultGF("gf-pixel")
end

function Stage:createPost()
    print(bg.x, bg.y, bg.width, bg.height, PlayState.boyfriend.x, PlayState.boyfriend.y)
end

function Stage:beatHit()
    if self.bgGirls then self.bgGirls:dance() end
end

function Stage:eventPushed(event)
    if event.event == "Trigger BG Ghouls" then
        self.bgGhouls = BGSprite("stages/school/bgGhouls", -100, 190, 0.9, 0.9, {"BG freaks glitch instance"}, false)
        self.bgGhouls:setGraphicSize(math.floor(self.bgGhouls.width * PlayState.daPixelZoom))
        self.bgGhouls.visible = false
        self.bgGhouls.antialiasing = false
        self.bgGhouls.callback = function(self, name)
            if name == "BG freaks glitch instance" then
                self.visible = false
            end
        end
        self:addBehindGF(self.bgGhouls)
    end
end

function Stage:eventCalled(eventName, v1, v2, fv1, fv2, strumTime)
    if eventName == "Trigger BG Ghouls" then
        self.bgGhouls:dance(true)
        self.bgGhouls.visible = true
    end
end

return Stage