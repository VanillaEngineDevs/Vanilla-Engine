local function setupImports()
    HScript.ctx.import = {
        ["funkin.play.PlayState"] = {
            instance = {
                currentSong = {
                    id = {
                        toLowerCase = function(self)
                            return SONGID:lower()
                        end
                    }
                }
            }
        },

        ["funkin.play.stage.Stage"] = {
            
        }
    }

    HScript.main:setContext(HScript.ctx)
end

return setupImports
