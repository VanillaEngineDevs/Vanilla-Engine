local StageProp = FunkinSprite:extend("StageProp")
StageProp:implement(IStateStageProp)
StageProp:implement(INoteScriptedClass)

function StageProp:new(name)
    FunkinSprite.new(self)

    self.name = name or "Unknown Prop"
end

function StageProp:onAdd(e)
end

function StageProp:onScriptEvent(e)
end

function StageProp:onCreate(e)
end

function StageProp:onDestroy()
end

function StageProp:onUpdate(e)
end

return StageProp