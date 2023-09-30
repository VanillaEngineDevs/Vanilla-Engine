local Stage = BaseStage:extend()

Stage.bgGhouls = nil
Stage.doof = nil
Stage.music = nil
Stage.senpaiEvil = nil

function Stage:create()
    
end

function Stage:beatHit()
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