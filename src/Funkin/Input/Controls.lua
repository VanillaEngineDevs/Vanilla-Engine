local Controls = Class:extend()

local function CreateENUM(tbl)
    local enum = {}
    for _, v in ipairs(tbl) do
        enum[v] = v
    end
    return enum
end

ActionEnum = CreateENUM({
    "NOTE_UP",
    "NOTE_LEFT",
    "NOTE_RIGHT",
    "NOTE_DOWN",
    "NOTE_UP_P",
    "NOTE_LEFT_P",
    "NOTE_RIGHT_P",
    "NOTE_DOWN_P",
    "NOTE_UP_R",
    "NOTE_LEFT_R",
    "NOTE_RIGHT_R",
    "NOTE_DOWN_R",
    "UI_UP",
    "UI_LEFT",
    "UI_RIGHT",
    "UI_DOWN",
    "UI_UP_P",
    "UI_LEFT_P",
    "UI_RIGHT_P",
    "UI_DOWN_P",
    "UI_UP_R",
    "UI_LEFT_R",
    "UI_RIGHT_R",
    "UI_DOWN_R",
    "ACCEPT",
    "BACK",
    "PAUSE",
    "RESET",
    "WINDOW_FULLSCREEN",
    "CUTSCENE_ADVANCE",
    "FREEPLAY_FAVORITE",
    "FREEPLAY_LEFT",
    "FREEPLAY_RIGHT",
    "FREEPLAY_CHAR_SELECT",
    "FREEPLAY_JUMP_TO_TOP",
    "FREEPLAY_JUMP_TO_BOTTOM",
    "VOLUME_UP",
    "VOLUME_DOWN",
    "VOLUME_MUTE"
})

function ActionToString(action)
    if action == ActionEnum.NOTE_UP then return "note_up"
    elseif action == ActionEnum.NOTE_LEFT then return "note_left"
    elseif action == ActionEnum.NOTE_RIGHT then return "note_right"
    elseif action == ActionEnum.NOTE_DOWN then return "note_down"
    elseif action == ActionEnum.NOTE_UP_P then return "note_up-press"
    elseif action == ActionEnum.NOTE_LEFT_P then return "note_left-press"
    elseif action == ActionEnum.NOTE_RIGHT_P then return "note_right-press"
    elseif action == ActionEnum.NOTE_DOWN_P then return "note_down-press"
    elseif action == ActionEnum.NOTE_UP_R then return "note_up-release"
    elseif action == ActionEnum.NOTE_LEFT_R then return "note_left-release"
    elseif action == ActionEnum.NOTE_RIGHT_R then return "note_right-release"
    elseif action == ActionEnum.NOTE_DOWN_R then return "note_down-release"
    elseif action == ActionEnum.UI_UP then return "ui_up"
    elseif action == ActionEnum.UI_LEFT then return "ui_left"
    elseif action == ActionEnum.UI_RIGHT then return "ui_right"
    elseif action == ActionEnum.UI_DOWN then return "ui_down"
    elseif action == ActionEnum.UI_UP_P then return "ui_up-press"
    elseif action == ActionEnum.UI_LEFT_P then return "ui_left-press"
    elseif action == ActionEnum.UI_RIGHT_P then return "ui_right-press"
    elseif action == ActionEnum.UI_DOWN_P then return "ui_down-press"
    elseif action == ActionEnum.UI_UP_R then return "ui_up-release"
    elseif action == ActionEnum.UI_LEFT_R then return "ui_left-release"
    elseif action == ActionEnum.UI_RIGHT_R then return "ui_right-release"
    elseif action == ActionEnum.UI_DOWN_R then return "ui_down-release"
    elseif action == ActionEnum.ACCEPT then return "accept"
    elseif action == ActionEnum.BACK then return "back"
    elseif action == ActionEnum.PAUSE then return "pause"
    elseif action == ActionEnum.RESET then return "reset"
    elseif action == ActionEnum.WINDOW_FULLSCREEN then return "window_fullscreen"
    elseif action == ActionEnum.CUTSCENE_ADVANCE then return "cutscene_advance"
    elseif action == ActionEnum.FREEPLAY_FAVORITE then return "freeplay_favorite"
    elseif action == ActionEnum.FREEPLAY_LEFT then return "freeplay_left"
    elseif action == ActionEnum.FREEPLAY_RIGHT then return "freeplay_right"
    elseif action == ActionEnum.FREEPLAY_CHAR_SELECT then return "freeplay_char_select"
    elseif action == ActionEnum.FREEPLAY_JUMP_TO_TOP then return "freeplay_jump_to_top"
    elseif action == ActionEnum.FREEPLAY_JUMP_TO_BOTTOM then return "freeplay_jump_to_bottom"
    elseif action == ActionEnum.VOLUME_UP then return "volume_up"
    elseif action == ActionEnum.VOLUME_DOWN then return "volume_down"
    elseif action == ActionEnum.VOLUME_MUTE then return "volume_mute"
    else return nil
    end
end

function ActionGetKeys(action)
    if action == ActionEnum.NOTE_UP then return {"w", "up"}
    elseif action == ActionEnum.NOTE_LEFT then return {"a", "left"}
    elseif action == ActionEnum.NOTE_RIGHT then return {"d", "right"}
    elseif action == ActionEnum.NOTE_DOWN then return {"s", "down"}
    elseif action == ActionEnum.UI_UP then return {"up", "w"}
    elseif action == ActionEnum.UI_LEFT then return {"left", "a"}
    elseif action == ActionEnum.UI_RIGHT then return {"right", "d"}
    elseif action == ActionEnum.UI_DOWN then return {"down", "s"}
    elseif action == ActionEnum.ACCEPT then return {"return", "space", "z"}
    elseif action == ActionEnum.BACK then return {"escape", "x", "backspace"}
    elseif action == ActionEnum.PAUSE then return {"p"}
    elseif action == ActionEnum.RESET then return {"r"}
    elseif action == ActionEnum.WINDOW_FULLSCREEN then return {"f11"}
    elseif action == ActionEnum.CUTSCENE_ADVANCE then return {"return"}
    elseif action == ActionEnum.FREEPLAY_FAVORITE then return {"f"}
    elseif action == ActionEnum.FREEPLAY_LEFT then return {"left", "a"}
    elseif action == ActionEnum.FREEPLAY_RIGHT then return {"right", "d"}
    elseif action == ActionEnum.FREEPLAY_CHAR_SELECT then return {"tab"}
    elseif action == ActionEnum.FREEPLAY_JUMP_TO_TOP then return {"home"}
    elseif action == ActionEnum.FREEPLAY_JUMP_TO_BOTTOM then return {"end"}
    elseif action == ActionEnum.VOLUME_UP then return {"kp+", "="}
    elseif action == ActionEnum.VOLUME_DOWN then return {"kp-", "-"}
    elseif action == ActionEnum.VOLUME_MUTE then return {"m"}
    else return {}
    end
end

FunkinAction = Class:extend()

function FunkinAction:new(name, namePressed, nameReleased)
    self.namePressed = namePressed
    self.nameReleased = nameReleased
    self.keys = ActionGetKeys(name) or {}

    self.name = name

    self.cache = {}

    self.isDown = false
    self.justPressed = false
    self.justReleased = false
end

function FunkinAction:check()
    return self:checkFiltered("JUST_PRESSED")
end

function FunkinAction:checkPressed()
    return self:checkFiltered("PRESSED")
end

function FunkinAction:checkJustPressed()
    return self:checkFiltered("JUST_PRESSED")
end

function FunkinAction:checkReleased()
    return self:checkFiltered("RELEASED")
end

function FunkinAction:checkJustReleased()
    return self:checkFiltered("JUST_RELEASED")
end

function FunkinAction:update(dt)
    self.justPressed = false
    self.justReleased = false
end

function FunkinAction:checkFiltered(filterTrigger)
    local prev = self.isDown or false

    local anyDown = false
    for _, key in ipairs(self.keys) do
        if love.keyboard.isDown(key) then
            anyDown = true
            break
        end
    end

    -- set per-frame latches on transition; they persist until update() clears them
    if anyDown and not prev then
        self.justPressed = true
    end
    if not anyDown and prev then
        self.justReleased = true
    end

    self.isDown = anyDown

    if filterTrigger == "JUST_PRESSED" then
        return self.justPressed
    elseif filterTrigger == "PRESSED" then
        return self.isDown
    elseif filterTrigger == "JUST_RELEASED" then
        return self.justReleased
    elseif filterTrigger == "RELEASED" then
        return not self.isDown
    end

    return false
end

function Controls:new(name)
    self.name = name or "Controls"

    self._ui_up = FunkinAction(ActionEnum.UI_UP, "ui_up-press", "ui_up-release")

    self._ui_left = FunkinAction(ActionEnum.UI_LEFT, "ui_left-press", "ui_left-release")
    self._ui_right = FunkinAction(ActionEnum.UI_RIGHT, "ui_right-press", "ui_right-release")
    self._ui_down = FunkinAction(ActionEnum.UI_DOWN, "ui_down-press", "ui_down-release")
    self._note_up = FunkinAction(ActionEnum.NOTE_UP, "note_up-press", "note_up-release")
    self._note_left = FunkinAction(ActionEnum.NOTE_LEFT, "note_left-press", "note_left-release")
    self._note_right = FunkinAction(ActionEnum.NOTE_RIGHT, "note_right-press", "note_right-release")
    self._note_down = FunkinAction(ActionEnum.NOTE_DOWN, "note_down-press", "note_down-release")
    self._accept = FunkinAction(ActionEnum.ACCEPT, "accept", nil)

    self._back = FunkinAction(ActionEnum.BACK, "back", nil)
    self._pause = FunkinAction(ActionEnum.PAUSE, "pause", nil)
    self._reset = FunkinAction(ActionEnum.RESET, "reset", nil)
    self._window_fullscreen = FunkinAction(ActionEnum.WINDOW_FULLSCREEN, "window_fullscreen", nil)
    self._cutscene_advance = FunkinAction(ActionEnum.CUTSCENE_ADVANCE, "cutscene_advance", nil)
    self._freeplay_favorite = FunkinAction(ActionEnum.FREEPLAY_FAVORITE, "freeplay_favorite", nil)
    self._freeplay_left = FunkinAction(ActionEnum.FREEPLAY_LEFT, "freeplay_left", nil)
    self._freeplay_right = FunkinAction(ActionEnum.FREEPLAY_RIGHT, "freeplay_right", nil)
    self._freeplay_char_select = FunkinAction(ActionEnum.FREEPLAY_CHAR_SELECT, "freeplay_char_select", nil)
    self._freeplay_jump_to_top = FunkinAction(ActionEnum.FREEPLAY_JUMP_TO_TOP, "freeplay_jump_to_top", nil)
    self._freeplay_jump_to_bottom = FunkinAction(ActionEnum.FREEPLAY_JUMP_TO_BOTTOM, "freeplay_jump_to_bottom", nil)
    self._volume_up = FunkinAction(ActionEnum.VOLUME_UP, "volume_up", nil)
    self._volume_down = FunkinAction(ActionEnum.VOLUME_DOWN, "volume_down", nil)
    self._volume_mute = FunkinAction(ActionEnum.VOLUME_MUTE, "volume_mute", nil)
    self.byName = {}

    for _, action in pairs(ActionEnum) do
        if string.endsWith(action, "_P") or string.endsWith(action, "_R") then
            goto continue
        end
        local actionStr = ActionToString(action)
        if actionStr ~= nil then
            local funkinAction = self["_" .. actionStr:gsub("-", "_")]
            self.byName[funkinAction.name] = funkinAction
            if funkinAction ~= nil then
                if funkinAction.namePressed ~= nil then
                    self.byName[funkinAction.namePressed] = funkinAction
                end
                if funkinAction.nameReleased ~= nil then
                    self.byName[funkinAction.nameReleased] = funkinAction
                end
            end
        end

        ::continue::
    end

    function self:UI_UP() return self._ui_up:checkPressed() end
    function self:UI_LEFT() return self._ui_left:checkPressed() end
    function self:UI_RIGHT() return self._ui_right:checkPressed() end
    function self:UI_DOWN() return self._ui_down:checkPressed() end
    function self:UI_UP_P() return self._ui_up:checkJustPressed() end
    function self:UI_LEFT_P() return self._ui_left:checkJustPressed() end
    function self:UI_RIGHT_P() return self._ui_right:checkJustPressed() end
    function self:UI_DOWN_P() return self._ui_down:checkJustPressed() end
    function self:UI_UP_R() return self._ui_up:checkJustReleased() end
    function self:UI_LEFT_R() return self._ui_left:checkJustReleased() end
    function self:UI_RIGHT_R() return self._ui_right:checkJustReleased() end
    function self:UI_DOWN_R() return self._ui_down:checkJustReleased() end

    function self:NOTE_UP() return self._note_up:checkPressed() end
    function self:NOTE_LEFT() return self._note_left:checkPressed() end
    function self:NOTE_RIGHT() return self._note_right:checkPressed() end
    function self:NOTE_DOWN() return self._note_down:checkPressed() end
    function self:NOTE_UP_P() return self._note_up:checkJustPressed() end
    function self:NOTE_LEFT_P() return self._note_left:checkJustPressed() end
    function self:NOTE_RIGHT_P() return self._note_right:checkJustPressed() end
    function self:NOTE_DOWN_P() return self._note_down:checkJustPressed() end
    function self:NOTE_UP_R() return self._note_up:checkJustReleased() end
    function self:NOTE_LEFT_R() return self._note_left:checkJustReleased() end
    function self:NOTE_RIGHT_R() return self._note_right:checkJustReleased() end
    function self:NOTE_DOWN_R() return self._note_down:checkJustReleased() end

    function self:ACCEPT() return self._accept:checkJustPressed() end
    function self:BACK() return self._back:checkJustPressed() end
    function self:PAUSE() return self._pause:checkJustPressed() end
    function self:RESET() return self._reset:checkJustPressed() end

    function self:WINDOW_FULLSCREEN() return self._window_fullscreen:checkJustPressed() end
    function self:CUTSCENE_ADVANCE() return self._cutscene_advance:checkPressed() end
    function self:FREEPLAY_FAVORITE() return self._freeplay_favorite:checkJustPressed() end

    function self:FREEPLAY_LEFT() return self._freeplay_left:checkJustPressed() end
    function self:FREEPLAY_RIGHT() return self._freeplay_right:checkJustPressed() end
    function self:FREEPLAY_CHAR_SELECT() return self._freeplay_char_select:checkJustPressed() end
    function self:FREEPLAY_JUMP_TO_TOP() return self._freeplay_jump_to_top:checkJustPressed() end
    function self:FREEPLAY_JUMP_TO_BOTTOM() return self._freeplay_jump_to_bottom:checkJustPressed() end

    function self:VOLUME_UP() return self._volume_up:checkJustPressed() end
    function self:VOLUME_DOWN() return self._volume_down:checkJustPressed() end
    function self:VOLUME_MUTE() return self._volume_mute:checkJustPressed() end
end

function Controls:check(name, trigger)
    trigger = trigger or "JUST_PRESSED"

    local action = self.byName[name]
    return action:checkFiltered(trigger)
end

function Controls:getKeysForAction(name)
    local action = self.byName[name]
    if action then
        return action.keys
    else
        return {}
    end
end

function Controls:getActionFromControl(ctrl)
    if ctrl == Controls.UI_UP then return self._ui_up
    elseif ctrl == Controls.UI_LEFT then return self._ui_left
    elseif ctrl == Controls.UI_RIGHT then return self._ui_right
    elseif ctrl == Controls.UI_DOWN then return self._ui_down
    elseif ctrl == Controls.NOTE_UP then return self._note_up
    elseif ctrl == Controls.NOTE_LEFT then return self._note_left
    elseif ctrl == Controls.NOTE_RIGHT then return self._note_right
    elseif ctrl == Controls.NOTE_DOWN then return self._note_down
    elseif ctrl == Controls.ACCEPT then return self._accept
    elseif ctrl == Controls.BACK then return self._back
    elseif ctrl == Controls.PAUSE then return self._pause
    elseif ctrl == Controls.RESET then return self._reset
    elseif ctrl == Controls.WINDOW_FULLSCREEN then return self._window_fullscreen
    elseif ctrl == Controls.CUTSCENE_ADVANCE then return self._cutscene_advance
    elseif ctrl == Controls.FREEPLAY_FAVORITE then return self._freeplay_favorite
    elseif ctrl == Controls.FREEPLAY_LEFT then return self._freeplay_left
    elseif ctrl == Controls.FREEPLAY_RIGHT then return self._freeplay_right
    elseif ctrl == Controls.FREEPLAY_CHAR_SELECT then return self._freeplay_char_select
    elseif ctrl == Controls.FREEPLAY_JUMP_TO_TOP then return self._freeplay_jump_to_top
    elseif ctrl == Controls.FREEPLAY_JUMP_TO_BOTTOM then return self._freeplay_jump_to_bottom
    elseif ctrl == Controls.VOLUME_UP then return self._volume_up
    elseif ctrl == Controls.VOLUME_DOWN then return self._volume_down
    elseif ctrl == Controls.VOLUME_MUTE then return self._volume_mute
    else return nil
    end
end

return Controls