local NoteStyleRegistry = BaseRegistry:extend()

NoteStyleRegistry.NOTE_STYLE_DATA_VERSION = "1.1.0"
NoteStyleRegistry.NOTE_STYLE_DATA_VERSION_RULE = "x.x.x"

function NoteStyleRegistry:getInstance()
    if not NoteStyleRegistry.instance then
        NoteStyleRegistry()
    end

    return NoteStyleRegistry.instance
end

function NoteStyleRegistry:new()
    NoteStyleRegistry.instance = self
    BaseRegistry.new(self, "NOTESTYLE", "notestyles", self.NOTE_STYLE_DATA_VERSION_RULE)
end

function NoteStyleRegistry:fetchDefault()
    return self:fetchEntry(Constants.DEFAULT_NOTE_STYLE)
end

function NoteStyleRegistry:parseEntryData(id)
    if not self.entries[id] then
        error("NoteStyleRegistry:parseEntryData - Entry with ID '" .. id .. "' does not exist.")
    end

    local entryFile = self:loadEntryFile(id)

    return Json.decode(entryFile.contents)
end

function NoteStyleRegistry:parseEntryDataRaw(contents, fileName)
    return Json.decode(contents)
end

return NoteStyleRegistry