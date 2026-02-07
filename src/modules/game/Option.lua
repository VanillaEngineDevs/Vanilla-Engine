---@diagnostic disable: undefined-global
local Option = {}

Option.__index = Option

Option.child = nil
Option.text = ""
Option.onChange = nil

Option.type = "bool"

Option.scrollSpeed = 50
Option.variable = nil
Option.defaultValue = nil

Option.curOption = 1
Option.options = {}
Option.changeValue = 1
Option.minValue = 0
Option.maxValue = 0
Option.decimals = 1

Option.displayFormat = "%v"
Option.description = ""
Option.name = "Unknown"

function Option:new(name, description, variable, type, options, min, max)
    local description = description or ""
    local variable = variable == nil and false or variable
    local type = type or "bool"
    
    -- make newOption a clone of Option
    local newOption = setmetatable({}, Option)

    newOption.name = name
    newOption.description = description
    newOption.variable = variable == nil and false or variable
    newOption.type = type
    newOption.defaultValue = variable
    newOption.options = options or {}

    if defaultValue == "nil variable value" then
        if self.type == "bool" then
            newOption.defaultValue = false
        elseif self.type == "number" then
            newOption.defaultValue = 0
        elseif self.type == "percent" then
            newOption.defaultValue = 1
        elseif self.type == "string" then
            newOption.defaultValue = ""
            if self.length > 0 then
                newOption.defaultValue = self.options[1]
            end
        end
    end

    self.minValue = min
    self.maxValue = max

    if self.type == "string" then
        local num = self.options:indexOf(self.defaultValue)
        if num > -1 then
            self.curOption = num
        end
    elseif self.type == "percent" then
        self.displayFormat = "%v%"
        self.changeValue = 0.01
        self.minValue = 0
        self.maxValue = 1
        self.scrollSpeed = 0.5
        self.decimals = 3
    elseif self.type == "float" then
        self.changeValue = 0.1
        self.scrollSpeed = 0.5
        self.decimals = 2
        self.displayFormat = "%v"
    elseif self.type == "number" then
        self.changeValue = 1
        self.scrollSpeed = 0.5
        self.decimals = 0
        self.displayFormat = "%v"
    end

    return newOption
end

function Option:getValue()
    return self.variable
end

function Option:setValue(value)
    self.variable = value
    self:change()
end

function Option:change()
    if self.onChange then self.onChange() end
end

return Option