local curdir = (...):match("(.-)[^%.]+$")
local class = require(curdir .. "class")

local Bytes = class:extend("Bytes")

function Bytes:new(bin)
    self.bin = bin
    self.pin = 1

    self.bout = {}
    self.hstrings = {}
    self.strings = {false}
    self.nstrings = 1
end

local function addByte(buf, v)
    buf[#buf+1] = string.char(v)
end

local function addInt32(buf, v)
    local b1 = bit.band(v, 0xFF)
    local b2 = bit.band(bit.rshift(v, 8), 0xFF)
    local b3 = bit.band(bit.rshift(v, 16), 0xFF)
    local b4 = bit.band(bit.rshift(v, 24), 0xFF)
    buf[#buf+1] = string.char(b1, b2, b3, b4)
end

local function getByte(self)
    local b = string.byte(self.bin, self.pin)
    self.pin = self.pin + 1
    return b
end

local function getInt32(self)
    local b1, b2, b3, b4 = string.byte(self.bin, self.pin, self.pin + 3)
    self.pin = self.pin + 4
    return b1 + bit.lshift(b2, 8) + bit.lshift(b3, 16) + bit.lshift(b4, 24)
end

function Bytes:doEncodeString(v)
    local vid = self.hstrings[v]

    if not vid then
        if self.nstrings == 256 then
            self.hstrings = {}
            self.nstrings = 1
        end

        self.hstrings[v] = self.nstrings

        addByte(self.bout, 0)
        addByte(self.bout, #v)
        self.bout[#self.bout+1] = v

        self.nstrings = self.nstrings + 1
    else
        addByte(self.bout, vid)
    end
end

function Bytes:doDecodeString()
    local id = getByte(self)

    if id == 0 then
        local len = string.byte(self.bin, self.pin)
        local str = self.bin:sub(self.pin + 1, self.pin + len)

        self.pin = self.pin + len + 1

        if #self.strings == 255 then
            self.strings = {false}
        end

        table.insert(self.strings, str)

        return str
    end

    return self.strings[id]
end

function Bytes:doEncodeInt(v)
    addInt32(self.bout, v)
end

function Bytes:doDecodeInt()
    return getInt32(self)
end

function Bytes:doEncodeConst(c)
    if c.tag == "CInt" then
        local v = c.v

        if v >= 0 and v <= 255 then
            addByte(self.bout, 0)
            addByte(self.bout, v)
        else
            addByte(self.bout, 1)
            self:doEncodeInt(v)
        end
    elseif c.tag == "CFloat" then
        addByte(self.bout, 2)
        self:doEncodeString(tostring(c.f))
    elseif c.tag == "CString" then
        addByte(self.bout, 3)
        self:doEncodeString(c.s)
    end
end

function Bytes:doDecodeConst()
    local t = getByte(self)

    if t == 0 then
        return {tag="CInt", v=getByte(self)}
    elseif t == 1 then
        return {tag="CInt", v=self:doDecodeInt()}
    elseif t == 2 then
        return {tag="CFloat", f=tonumber(self:doDecodeString())}
    elseif t == 3 then
        return {tag="CString", s=self:doDecodeString()}
    end

    error("Invalid const code "..t)
end

local exprIDs = {
    EConst=0,
    EIdent=1,
    EVar=2,
    EParent=3,
    EBlock=4,
    EField=5,
    EBinop=6,
    EUnop=7,
    ECall=8,
    EIf=9,
    EWhile=10,
    EFor=11,
    EBreak=12,
    EContinue=13,
    EFunction=14,
    EReturn=15,
    EArray=16,
    EArrayDecl=17,
    ENew=18,
    EThrow=19,
    ETry=20,
    EObject=21,
    ETernary=22,
    ESwitch=23,
    EDoWhile=24,
    EMeta=25,
    ECheckType=26,
    EForGen=27
}

function Bytes:doEncode(e)
    addByte(self.bout, exprIDs[e.tag])

    local tag = e.tag

    if tag == "EConst" then
        self:doEncodeConst(e.c)
    elseif tag == "EIdent" then
        self:doEncodeString(e.v)
    elseif tag == "EVar" then
        self:doEncodeString(e.n)

        if not e.e then
            addByte(self.bout, 255)
        else
            self:doEncode(e.e)
        end
    elseif tag == "EParent" then
        self:doEncode(e.e)
    elseif tag == "EBlock" then
        addByte(self.bout, #e.e)
        for _, v in ipairs(e.e) do
            self:doEncode(v)
        end
    elseif tag == "EBinop" then
        self:doEncodeString(e.op)
        self:doEncode(e.e1)
        self:doEncode(e.e2)
    elseif tag == "ECall" then
        self:doEncode(e.e)
        addByte(self.bout, #e.params)
        for _, p in ipairs(e.params) do
            self:doEncode(p)
        end
    elseif tag == "EReturn" then
        if not e.e then
            addByte(self.bout, 255)
        else
            self:doEncode(e.e)
        end
    end
end

function Bytes:doDecode()
    local id = getByte(self)

    if id == 255 then
        return nil
    end

    if id == 0 then
        return {tag="EConst", c=self:doDecodeConst()}
    elseif id == 1 then
        return {tag="EIdent", v=self:doDecodeString()}
    elseif id == 2 then
        local v = self:doDecodeString()
        return {tag="EVar", n=v, e=self:doDecode()}
    elseif id == 3 then
        return {tag="EParent", e=self:doDecode()}
    elseif id == 4 then
        local n = getByte(self)
        local a = {}

        for i=1,n do
            a[i] = self:doDecode()
        end

        return {tag="EBlock", e=a}
    elseif id == 6 then
        local op = self:doDecodeString()
        local e1 = self:doDecode()
        local e2 = self:doDecode()

        return {tag="EBinop", op=op, e1=e1, e2=e2}
    elseif id == 8 then
        local fn = self:doDecode()
        local n = getByte(self)

        local params = {}

        for i=1,n do
            params[i] = self:doDecode()
        end

        return {tag="ECall", e=fn, params=params}
    elseif id == 15 then
        return {tag="EReturn", e=self:doDecode()}
    end

    error("Unsupported expr id "..id)
end

function Bytes.encode(expr)
    local b = Bytes()
    b:doEncode(expr)
    return table.concat(b.bout)
end

function Bytes.decode(data)
    local b = Bytes(data)
    return b:doDecode()
end

return Bytes