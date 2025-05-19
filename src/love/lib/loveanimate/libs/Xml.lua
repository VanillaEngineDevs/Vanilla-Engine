-- XML parser made by Stilic for FNF LÖVE
---
-- Originally based off https://github.com/Cluain/Lua-Simple-XML-Parser
-- Taken from https://github.com/Stilic/FNF-LOVE/blob/main/loxel/lib/xml.lua

local tblInsert = table.insert
local tblRemove = table.remove

local function trim(str) return string.match(str, "^%s*(.-)%s*$") end

local function endsWith(str, ending)
    return ending == "" or string.sub(str, - #ending) == ending
end

local function count(str, pattern)
    return select(2, string.gsub(str, pattern, ""))
end

local function fromXmlString(value)
    value = string.gsub(value, "&#x([%x]+)%",
        function(h) return string.char(tonumber(h, 16)) end)
    value = string.gsub(value, "&#([0-9]+)%",
        function(h) return string.char(tonumber(h, 10)) end)
    value = string.gsub(value, "&quot", "\"")
    value = string.gsub(value, "&apos", "'")
    value = string.gsub(value, "&gt", ">")
    value = string.gsub(value, "&lt", "<")
    value = string.gsub(value, "&amp", "&")
    return value
end

local function parseArgs(node, s)
    return string.gsub(s, "(%w+)=([\"'])(.-)%2",
        function(w, _, a) node:setAtt(w, fromXmlString(a)) end)
end

local function newNode(name)
    local node = {}
    node.value = nil
    node.name = name
    node.children = {}
    node.att = {}

    function node:addChild(child)
        if self[child.name] then
            if type(self[child.name].name) == "function" then
                local tempTable = {}
                tblInsert(tempTable, self[child.name])
                self[child.name] = tempTable
            end
            tblInsert(self[child.name], child)
        else
            self[child.name] = child
        end
        tblInsert(self.children, child)
    end

    function node:setAtt(name, value)
        if self.att[name] then
            if type(self.att[name]) == "string" then
                local tempTable = {}
                tblInsert(tempTable, self.att[name])
                self.att[name] = tempTable
            end
            tblInsert(self.att[name], value)
        else
            self.att[name] = value
        end
    end

    return node
end

---
--- @class love.animate.libs.Xml
---
local xml = {}

function xml.parse(xmlText)
    local stack = {}
    local top = newNode()
    tblInsert(stack, top)
    local i = 1
    while true do
        local ni, j, c, label, xarg, empty =
            string.find(xmlText, "<(%/?)([%w_:]+)(.-)(%/?)>", i)
        if not ni then break end
        local text = trim(string.sub(xmlText, i, ni - 1))
        local addNode = true
        if not string.find(text, "^%s*$") then
            if endsWith(text, "/>") and count(text, '"') % 2 ~= 0 then
                local xargEnd = string.sub(text, 1, #text - 2)
                local first = string.find(xmlText, xargEnd, i, true) - 1
                xargEnd = string.sub(xmlText, first, first) .. xargEnd
                xarg = string.sub(xarg, 1, string.find(xarg, '"', 1, true)) ..
                    xargEnd
                empty = "/"
            else
                stack[#stack].value = (top.value or "") .. fromXmlString(text)
            end
        else
            addNode = count(xarg, '"') % 2 == 0
        end
        if addNode then
            if empty == "/" then -- empty element tag
                local lNode = newNode(label)
                parseArgs(lNode, xarg)
                top:addChild(lNode)
            elseif c == "" then -- start tag
                local lNode = newNode(label)
                parseArgs(lNode, xarg)
                tblInsert(stack, lNode)
                top = lNode
            else                                    -- end tag
                local toclose = tblRemove(stack) -- remove top

                top = stack[#stack]
                if #stack < 1 then
                    error("parser: nothing to close with " .. label)
                end
                local name = toclose.name
                if name ~= label then
                    error("parser: trying to close " .. name .. " with " ..
                        label)
                end
                top:addChild(toclose)
            end
        end
        i = j + 1
    end
    if #stack > 1 then error("parser: unclosed " .. stack[#stack].name) end
    return top
end

return xml