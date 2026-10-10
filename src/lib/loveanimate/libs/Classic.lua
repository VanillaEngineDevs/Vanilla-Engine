--
-- https://github.com/rxi/classic
--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--
-- Modified for FNF-Aster purposes, ralty
-- Modified syntax slightly, swordcube
--

---
--- @class loveanimate.libs.Class
---
local Class = {__class = "Class"}
Class.__index = Class

function Class:constructor(...) end

function Class:extend(type, path)
	local cls = {}

	for k, v in pairs(self) do
		if k:sub(1, 2) == "__" then cls[k] = v end
	end

	cls.__class = type or ("Unknown(" .. self.__class .. ")")
	cls.__path = path
	cls.__index = cls
	cls.super = self
	setmetatable(cls, self)

	return cls
end

function Class:implement(...)
	for _, cls in pairs({...}) do
		for k, v in pairs(cls) do
			if self[k] == nil and type(v) == "function" and k ~= "constructor" and k ~= "new" and k:sub(1, 2) ~= "__" then
				self[k] = v
			end
		end
	end
end

function Class:exclude(...)
	for i = 1, select("#", ...) do
		self[select(i, ...)] = nil
	end
end

function Class:is(T)
	local mt = self
	repeat
		mt = getmetatable(mt)
		if mt == T then return true end
	until mt == nil
	return false
end

function Class:__tostring() return self.__class end

function Class:new(...)
	local obj = setmetatable({}, self)
	obj:constructor(...)
	return obj
end

return Class