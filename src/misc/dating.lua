dialogues = {
    -- the tables are for options, the tables inside are for the love level
    ["Hold Hands"] = {
        { 
            {
                "Tankman: What? You want to hold hands?",
                "Tankman: Are you joking?",
            }
        },
        { 
            {
                "Tankman: *AHEM* I mean, sure, I guess...",
                "Tankman: I'm not really used to this kind of thing, but I'll try my best..."
            }
        },
        { 
            {
                "Tankman: Your hands are so soft...",
                "Tankman: I can hold them forever..."
            }
        },
        { 
            {
                "Tankman: I love you so much...",
                "Tankman: I can't wait to spend the rest of my life with you..."
            }
        },
        { 
            {
                "Tankman: I love you so much.",
            }

        },
    },
    ["Hug"] = {
        {
            {
                "Tankman: A hug? What? you feeling down or something?",
                "Tankman: I mean, I guess I can give you a hug",
            }
        },
        {
            {
                "Tankman: A-are you sure you want a hug?",
                "Tankman: I mean, sure, I guess...",
            }
        },
        {
            {
                "Tankman: Your hugs are so warm...",
                "Tankman: I can stay like this forever...",
            }
        },
        {
           {
                "Tankman: I love you so much...",
                "Tankman: I just want to hold you forever...",
           }
        },
        {
           {
                "Tankman: I love you so much."
           }
        }
    },
    ["Kiss"] = {
        {
            {
                "Tankman: What are you doing?",
                "Tankman: What do you mean you want to kiss me?",
                "Tankman: No. I'm not gonna do that."
            }
        },
        {
            {
                "Tankman: A kiss? Are you sure?",
                "Tankman: A little kiss won't hurt, I guess..."
            }
        },
        {
            {
                "Tankman: Your lips are so soft...",
                "Tankman: I can kiss them forever...",
            }
        },
        {
            {
                "Tankman: I love you so much...",
                "Tankman: HAMBUGER!!!!!!!!!!!!!!!!!!!!!!!",
            }
        },
        {
            {
                "Tankman: I love you so much."
            }
        }
    },
    ["Gift"] = {
        {
            {
                "Tankman: A gift? For me?",
                "Tankman: You shouldn't have...",
            }
        },
        {
            {
                "Tankman: A gift? For me?",
                "Tankman: You shouldn't have...",
            }
        },
        {
            {
                "Tankman: A gift? For me?",
                "Tankman: You shouldn't have...",
            }
        },
        {
            {
                "Tankman: A gift? For me?",
                "Tankman: You shouldn't have...",
            }
        },
        {
            {
                "Tankman: A gift? For me?",
                "Tankman: You shouldn't have...",
            }
        }
    },
    ["Levels"] = { -- dialogue for each level up
        {
            {
                "Tankman: Hey good looking, what's cooking?",
                "Tankman: I'm just kidding, I'm not that smooth.",
            }
        },
        {
            {
                "Tankman: Hey, you look nice today.",
                "Tankman: I mean, you look nice everyday, but today you look extra nice.",
            }
        },
        {
            {
                "Tankman: Hey, I love you.",
                "Tankman: I mean, I love you everyday, but today I love you extra.",
            }
        },
        {
            {
                "Tankman: You're the best thing that's ever happened to me.",
                "Tankman: I hope we can stay together forever.",
            }
        },
        {
            {
                "Tankman: I love you so much.",
                "Tankman: I can't believe I'm so lucky to have you.",
            }
        }
    },

    ["Chat"] = {
        {
            {
                "Tankman: Hey, how's it going?",
                "Tankman: I'm just chilling, you?",
            }
        },
        {
            {
                "Tankman: Hey, handsome.",
                "Tankman: What are you up to?",
            }
        },
        {
            {
                "Tankman: Hey, I love you.",
                "Tankman: I hope you're having a good day.",
            }
        },
        {
            {
                "Tankman: Hey... Guess what?",
                "Tankman: I love you.",
                "Tankman: And I always will.",
            }
        },
        {
            {
                "Tankman: I love you so much.",
                "Tankman: I can't believe I'm so lucky to have you.",
            }
        }
    }
}

local dialogue = {
    dialogue = {},
    cur = 1,
    timer = 0,
    progress = 1,
    output = "",
    isDone = false,
    
    callback = function() end,

    setDialogue = function(self, dialogue)
        self.dialogue = dialogue
        self.cur = 1
        self.timer = 0
        self.progress = 1
        self.output = ""
        self.isDone = false
        self.length = #dialogue[love.math.random(1, #dialogue)][self.cur]
    end,

    advance = function(self)
        if self.isDone then return end

        self.cur = self.cur + 1
        self.timer = 0
        self.progress = 1
        self.output = ""

        if self.cur > #self.dialogue[love.math.random(1, #dialogue)] then
            self.isDone = true
            self.callback()
        else
            self.length = #self.dialogue[love.math.random(1, #dialogue)][self.cur]
        end
    end,

    update = function(self, dt)
        if not inDialogue then return end
        if self.isDone then return end

        self.timer = self.timer + dt
        
        -- sub the current dialogue into the output
        self.output = self.dialogue[love.math.random(1, #dialogue)][self.cur]:sub(1, math.floor(self.timer * 30))
    end,

    draw = function(self)
        if self.isDone then return end

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 0, push.getHeight() - 100, push.getWidth(), 100)

        love.graphics.setColor(1,1,1)
        love.graphics.print(self.output, 10, push.getHeight() - 90)
    end
}

return {
    -- Clothing hangers favourite

    enter = function(self)
        tankman = love.filesystem.load("sprites/characters/tankmanCaptain.lua")()

        tankman:animate("idle", true)
        tankman.sizeX = -0.65
        tankman.sizeY = 0.65

        tankman.x = push.getWidth()/2 + 300
        tankman.y = push.getHeight()/2

        loveScore = 0
        loveLevel = 1
        loveScoreMax = 10
        loveLevelMax = 5
        -- love level 1, just friends
        -- love level 2, flirting
        -- love level 3, dating
        -- love level 4, engaged
        -- love level 5, married

        barGradient = graphics.newGradientHorizontal(
            {1,0,0},
            {1,0,0.1},
            {1,0,0.2},
            {1,0,0.3},
            {1,0,0.4},
            {1,0,0.5},
            {1,0,0.6},
            {1,0,0.7},
            {1,0,0.8},
            {1,0,0.9},
            {1,0,1}
        )

        -- gray gradient
        bgGradient = graphics.newGradient(
            {0.5,0.5,0.5},
            {0.75,0.75,0.75},
            {0.5,0.5,0.5},
            {0.75,0.75,0.75},
            {0.5,0.5,0.5},
            {0.75,0.75,0.75},
            {0.5,0.5,0.5}
        )

        love.window.setTitle("Friday Night Funkin' Vanilla Engine v1.0.0 - Tankman Dating Simulator")

        love.graphics.setDefaultFilter("nearest", "nearest")
        heart = graphics.newImage(graphics.imagePath("dating/heart"))
        -- determine heart.x from loveScore and 400px
        heart.x = 0
        heart.y = 22
        heart.sizeX, heart.sizeY = 1.5, 1.5

        buttons = {
            {
                label = "Chat"
            },
            {
                label = "Gift"
            },
            {
                label = "Hold Hands"
            },
            {
                label = "Hug"
            },
            {
                label = "Kiss"
            }
        }

        isButtonPress = false
        inDialogue = true

        dialogue:setDialogue(
            {
                {
                    "Tankman: Hey, dude! Hows it going?",
                    "Tankman: I'm so glad you're here.",
                    "Tankman: I've been waiting for you all day.",
                }
            }
        )
        dialogue.callback = function()
            inDialogue = false
        end
    end,

    update = function(self, dt)
        tankman:update(dt)
        dialogue:update(dt)

        if loveScore < 0 then
            loveScore = 0
        end
    end,

    mousepressed = function(self, x, y, button)
        if button == 1 then
            if not isButtonPress and not inDialogue then
                loveScore = loveScore + 1
                if loveScore >= loveScoreMax then
                    if loveLevel < loveLevelMax then
                        loveLevel = loveLevel + 1
                        loveScore = 0
                        loveScoreMax = loveScoreMax + 5

                        inDialogue = true
                        dialogue:setDialogue(dialogues["Levels"][loveLevel])
                        dialogue.callback = function()
                            inDialogue = false
                        end
                    else
                        loveScore = loveScoreMax
                    end
                end
            elseif not inDialogue then
                if isButtonPress then
                    -- check which button label has >
                    for i, button in ipairs(buttons) do
                        if button.label:find(">") then
                            inDialogue = true
                            dialogue:setDialogue(dialogues[button.label:gsub(">", "")][loveLevel])
                            dialogue.callback = function()
                                inDialogue = false
                            end
                            break
                        end
                    end
                end
            else
                dialogue:advance()
            end
        end
    end,

    mousemoved = function(self, x, y, dx, dy, istouch)
        for i, button in ipairs(buttons) do
            if x > 0 and x < 400 and y > 100*i and y < 100*i + 100 and not inDialogue then
                -- remove the ">" if it exists
                for j, button in ipairs(buttons) do
                    button.label = button.label:gsub(">", "")
                end
                button.label = ">" .. button.label

                isButtonPress = true

                break
            elseif not inDialogue then
                button.label = button.label:gsub(">", "")

                isButtonPress = false
            end
        end
    end,

    -- same stuff as mouse stuff, but with touch
    touchpressed = function(self, id, x, y, dx, dy, pressure)
        if not isButtonPress and not inDialogue then
            loveScore = loveScore + 1
            if loveScore >= loveScoreMax then
                if loveLevel < loveLevelMax then
                    loveLevel = loveLevel + 1
                    loveScore = 0
                    loveScoreMax = loveScoreMax + 5

                    inDialogue = true
                    dialogue:setDialogue(dialogues["Levels"][loveLevel])
                    dialogue.callback = function()
                        inDialogue = false
                    end
                else
                    loveScore = loveScoreMax
                end
            end
        elseif not inDialogue then
            if isButtonPress then
                -- check which button label has >
                for i, button in ipairs(buttons) do
                    if button.label:find(">") then
                        inDialogue = true
                        dialogue:setDialogue(dialogues[button.label:gsub(">", "")][loveLevel])
                        dialogue.callback = function()
                            inDialogue = false
                        end
                        break
                    end
                end
            end
        else
            dialogue:advance()
        end
    end,

    touchmoved = function(self, id, x, y, dx, dy, pressure)
        for i, button in ipairs(buttons) do
            if x > 0 and x < 400 and y > 100*i and y < 100*i + 100 and not inDialogue then
                -- remove the ">" if it exists
                for j, button in ipairs(buttons) do
                    button.label = button.label:gsub(">", "")
                end
                button.label = ">" .. button.label

                isButtonPress = true

                break
            elseif not inDialogue then
                button.label = button.label:gsub(">", "")

                isButtonPress = false
            end
        end
    end,

    draw = function(self)
        love.graphics.push()
            love.graphics.push()
                love.graphics.rotate(-0.7)
                love.graphics.draw(bgGradient, -480, 0, 0, graphics.getWidth()+225, graphics.getHeight()*2)
            love.graphics.pop()
            tankman:draw()

            love.graphics.draw(barGradient, 0, 0, 0, 400, 45)
            heart.x = (loveScore/loveScoreMax)*365 + 20
            heart:draw()

            -- draw buttons
            for i, button in ipairs(buttons) do
                love.graphics.push()
                    love.graphics.setColor(1,1,1)
                    love.graphics.translate(0, 100*i)
                    love.graphics.rectangle("fill", 0, 0, 400, 100)
                    love.graphics.setColor(0,0,0)
                    love.graphics.print(button.label, 20, 20)
                    love.graphics.setColor(1,1,1)
                love.graphics.pop()
            end

            if inDialogue then
                dialogue:draw()
            end
        love.graphics.pop()
    end,

    leave = function(self)

    end
}