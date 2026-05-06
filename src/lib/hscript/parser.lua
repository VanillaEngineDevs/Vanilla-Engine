local curdir = (...):match("(.-)[^%.]+$")
local class = require(curdir .. "class")
local AST = require(curdir .. "expr")
local bit = require("bit")
local utf8 = require("utf8")

local Expr = AST.Expr
local CType = AST.CType
local Const = AST.Const
local Err = AST.Error

local function eofChar(c)
	return c == nil or c < 0
end

local function toInt(n)
    ---@diagnostic disable-next-line: deprecated
	if math.tointeger then
        ---@diagnostic disable-next-line: deprecated
		local i = math.tointeger(n)
		if i ~= nil then return i end
	end
	return math.floor(n)
end

local function tok(tag, data)
	local t = { tag = tag }
	if data then
		for k, v in pairs(data) do
			t[k] = v
		end
	end
	return t
end

local function tokEq(a, b)
	if not a or not b then return false end
	if a.tag ~= b.tag then return false end
	if a.tag == "TConst" then
		local ca, cb = a.c, b.c
		if not ca or not cb then return false end
		if ca.tag ~= cb.tag then return false end
		if ca.tag == "CInt" then return ca.v == cb.v end
		if ca.tag == "CFloat" then return ca.f == cb.f end
		if ca.tag == "CString" then return ca.s == cb.s end
		return false
	end
	if a.tag == "TId" or a.tag == "TOp" or a.tag == "TMeta" or a.tag == "TPrepro" then
		return a.s == b.s
	end
	return true
end

local function listPop(stack)
	if #stack == 0 then return nil end
	return table.remove(stack)
end

local function isExprTag(e, tag)
	return e and e.tag == tag
end

local Parser = class:extend("Parser")

function Parser:new()
	self.line = 1
	self.opChars = "+*/-=!><&|^%~?"
	self.identChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"

	local priorities = {
		{ "%" },
		{ "*", "/" },
		{ "+", "-" },
		{ "<<", ">>", ">>>" },
		{ "|", "&", "^" },
		{ "==", "!=", ">", "<", ">=", "<=" },
		{ "..." },
		{ "&&" },
		{ "||" },
		{ "??" },
		{ "=", "+=", "-=", "*=", "/=", "%=", "<<=", ">>=", ">>>=", "??=", "|=", "&=", "^=", "=>" },
		{ "->" },
		{ "in", "is" },
	}

	self.opPriority = {}
	self.opRightAssoc = {}
	for i, arr in ipairs(priorities) do
		local pri = i - 1
		for _, x in ipairs(arr) do
			self.opPriority[x] = pri
			if pri == 10 then
				self.opRightAssoc[x] = true
			end
		end
	end

	for _, x in ipairs({ "!", "++", "--", "~" }) do
		self.opPriority[x] = (x == "++" or x == "--") and -1 or -2
	end

	self.preprocesorValues = {}
	self.allowJSON = false
	self.allowTypes = false
	self.allowMetadata = false
	self.resumeErrors = false

	self.input = ""
	self.readPos = 1
	self.offset = 0
	self.char = -1

	self.ops = {}
	self.idents = {}
	self.uid = 0

	self.tokenMin = 0
	self.tokenMax = 0
	self.oldTokenMin = 0
	self.oldTokenMax = 0
	self.tokens = {}

	self.preprocStack = {}
end

function Parser:currentPos()
	return (self.readPos - 1) + self.offset
end

function Parser:formatError(err)
	if type(err) == "table" then
		local tag = err.tag
		if tag == "EInvalidChar" then
			return ("Invalid char: %s"):format(string.char(err.c or 0))
		elseif tag == "EUnexpected" then
			return "Unexpected token " .. tostring(err.s)
		elseif tag == "EUnterminatedString" then
			return "Unterminated string"
		elseif tag == "EUnterminatedComment" then
			return "Unterminated comment"
		elseif tag == "EInvalidPreprocessor" then
			return "Invalid preprocessor: " .. tostring(err.msg)
		elseif tag == "EInvalidOp" then
			return "Invalid operator: " .. tostring(err.op)
		elseif tag == "ECustom" then
			return tostring(err.msg)
		end
	end
	return tostring(err)
end

function Parser:error(err, pmin, pmax)
	if self.resumeErrors then return end
	local msg = self:formatError(err)
	local pos = (pmin or self.tokenMin or 0) + 1
	error(("%s at line %d pos %d"):format(msg, self.line, pos), 0)
end

function Parser:invalidChar(c)
	self:error(Err.EInvalidChar(c), self.readPos - 1, self.readPos - 1)
end

function Parser:initParser(origin, pos)
	self.origin = origin or "hscript"
	self.preprocStack = {}
	self.readPos = 1
	self.offset = pos or 0
	self.char = -1
	self.uid = 0
	self.line = self.line or 1

	self.tokenMin = self.offset
	self.tokenMax = self.offset
	self.oldTokenMin = self.offset
	self.oldTokenMax = self.offset
	self.tokens = {}

	self.ops = {}
	self.idents = {}
	for i = 1, #self.opChars do
		self.ops[string.byte(self.opChars, i)] = true
	end
	for i = 1, #self.identChars do
		self.idents[string.byte(self.identChars, i)] = true
	end
end

function Parser:parseString(s, origin, position)
	self:initParser(origin or "hscript", position or 0)
	self.input = s or ""
	self.readPos = 1
	local a = {}
	while true do
		local tk = self:token()
		if tk.tag == "TEof" then break end
		self:push(tk)
		self:parseFullExpr(a)
	end
	if #a == 1 then return a[1] end
	return Expr.EBlock(a)
end

function Parser:unexpected(tk)
	self:error(Err.EUnexpected(self:tokenString(tk)), self.tokenMin, self.tokenMax)
	return nil
end

function Parser:push(tk)
	table.insert(self.tokens, {
		t = tk,
		min = self.tokenMin,
		max = self.tokenMax,
	})
	self.tokenMin = self.oldTokenMin
	self.tokenMax = self.oldTokenMax
end

function Parser:ensure(tk)
	local t = self:token()
	if not tokEq(t, tk) then self:unexpected(t) end
end

function Parser:ensureToken(tk)
	local t = self:token()
	if not tokEq(t, tk) then self:unexpected(t) end
end

function Parser:maybe(tk)
	local t = self:token()
	if tokEq(t, tk) then return true end
	self:push(t)
	return false
end

function Parser:getIdent()
	local tk = self:token()
	if tk.tag == "TId" then return tk.s end
	self:unexpected(tk)
	return nil
end

function Parser:isBlock(e)
	if not e then return false end
	local tag = e.tag
	if tag == "EBlock" or tag == "EObject" or tag == "ESwitch" then return true end
	if tag == "EClassDecl" or tag == "EClassDeclFull" then return true end
	if tag == "EImport" or tag == "EUsing" then return true end
	if tag == "EFunction" then return self:isBlock(e.e) end
	if tag == "EVar" or tag == "EFinal" then
		if e.e then return self:isBlock(e.e) end
		return e.t and e.t.tag == "CTAnon" or false
	end
	if tag == "EIf" then return self:isBlock(e.e2 or e.e1) end
	if tag == "EBinop" then return self:isBlock(e.e2) end
	if tag == "EUnop" then return (not e.prefix) and self:isBlock(e.e) or false end
	if tag == "EWhile" or tag == "EDoWhile" then return self:isBlock(e.e) end
	if tag == "EFor" or tag == "EForGen" then return self:isBlock(e.e) end
	if tag == "EReturn" then return e.e and self:isBlock(e.e) or false end
	if tag == "ETry" then return self:isBlock(e.ecatch) end
	if tag == "EMeta" then return self:isBlock(e.e) end
	return false
end

function Parser:parseFullExpr(exprs)
	local e = self:parseExpr()
	table.insert(exprs, e)

	local tk = self:token()
	while tk.tag == "TComma" and e and e.tag == "EVar" do
		e = self:parseStructure("var")
		table.insert(exprs, e)
		tk = self:token()
	end

	if tk.tag ~= "TSemicolon" and tk.tag ~= "TEof" then
		if self:isBlock(e) then
			self:push(tk)
		else
			self:unexpected(tk)
		end
	end
end

function Parser:parseObject()
	local fl = {}
	while true do
		local tk = self:token()
		local id = nil
		if tk.tag == "TId" then
			id = tk.s
		elseif tk.tag == "TConst" then
			if not self.allowJSON then self:unexpected(tk) end
			if tk.c.tag == "CString" then
				id = tk.c.s
			else
				self:unexpected(tk)
			end
		elseif tk.tag == "TBrClose" then
			break
		else
			self:unexpected(tk)
			break
		end

		self:ensure(tok("TDoubleDot"))
		table.insert(fl, { name = id, e = self:parseExpr() })
	
		if ident == "class" then
			local name = self:getIdent()
			local params = self:parseParams()
			local extend = nil
			local implement = {}
	
			while true do
				local t = self:token()
				if t.tag == "TId" and t.s == "extends" then
					extend = self:parseType()
				elseif t.tag == "TId" and t.s == "implements" then
					table.insert(implement, self:parseType())
				else
					self:push(t)
					break
				end
			end
	
			local fields = {}
			self:ensure(tok("TBrOpen"))
			while not self:maybe(tok("TBrClose")) do
				table.insert(fields, self:parseField())
			end
	
			return {
				tag = "DClass",
				decl = {
					name = name,
					meta = meta,
					params = params,
					extend = extend,
					implement = implement,
					fields = fields,
					isPrivate = isPrivate,
					isExtern = isExtern,
				}
			}
		end

		tk = self:token()
		if tk.tag == "TBrClose" then
			break
		elseif tk.tag ~= "TComma" then
			self:unexpected(tk)
		end
	end
	return self:parseExprNext(Expr.EObject(fl))
end

function Parser:parseExpr()
	local tk = self:token()
	local p1 = self.tokenMin

	if tk.tag == "TId" then
		local e = self:parseStructure(tk.s)
		if e == nil then e = Expr.EIdent(tk.s) end
		return self:parseExprNext(e)
	end

	if tk.tag == "TConst" then
		return self:parseExprNext(Expr.EConst(tk.c))
	end

	if tk.tag == "TPOpen" then
		tk = self:token()
		if tk.tag == "TPClose" then
			self:ensureToken(tok("TOp", { s = "->" }))
			local eret = self:parseExpr()
			return Expr.EFunction({}, Expr.EReturn(eret))
		end
		self:push(tk)
		local e = self:parseExpr()
		tk = self:token()
		if tk.tag == "TPClose" then
			return self:parseExprNext(Expr.EParent(e))
		elseif tk.tag == "TDoubleDot" then
			local t = self:parseType()
			tk = self:token()
			if tk.tag == "TPClose" then
				return self:parseExprNext(Expr.ECheckType(e, t))
			elseif tk.tag == "TComma" and e ~= nil and e.tag == "EIdent" then
				return self:parseLambda({ { name = e.v, t = t } }, p1)
			end
		elseif tk.tag == "TComma" and e ~= nil and e.tag == "EIdent" then
			return self:parseLambda({ { name = e.v } }, p1)
		end
		return self:unexpected(tk)
	end

	if tk.tag == "TBrOpen" then
		tk = self:token()
		if tk.tag == "TBrClose" then
			return self:parseExprNext(Expr.EObject({}))
		elseif tk.tag == "TId" then
			local tk2 = self:token()
			self:push(tk2)
			self:push(tk)
			if tk2.tag == "TDoubleDot" then
				return self:parseExprNext(self:parseObject())
			end
		elseif tk.tag == "TConst" then
			if self.allowJSON and tk.c.tag == "CString" then
				local tk2 = self:token()
				self:push(tk2)
				self:push(tk)
				if tk2.tag == "TDoubleDot" then
					return self:parseExprNext(self:parseObject())
				end
			else
				self:push(tk)
			end
		else
			self:push(tk)
		end

		local a = {}
		while true do
			self:parseFullExpr(a)
			tk = self:token()
			if tk.tag == "TBrClose" or (self.resumeErrors and tk.tag == "TEof") then break end
			self:push(tk)
		end
		return Expr.EBlock(a)
	end

	if tk.tag == "TOp" then
		local op = tk.s
		if op == "-" then
			local e = self:parseExpr()
			if e == nil then return self:makeUnop(op, e) end
			if e.tag == "EConst" and e.c.tag == "CInt" then
				return Expr.EConst(Const.CInt(-e.c.v))
			elseif e.tag == "EConst" and e.c.tag == "CFloat" then
				return Expr.EConst(Const.CFloat(-e.c.f))
			end
			return self:makeUnop(op, e)
		end
		if (self.opPriority[op] or 9999) < 0 then
			return self:makeUnop(op, self:parseExpr())
		end
		return self:unexpected(tk)
	end

	if tk.tag == "TBkOpen" then
		local a = {}
		tk = self:token()
		local first = true
		while tk.tag ~= "TBkClose" and (not self.resumeErrors or tk.tag ~= "TEof") do
			if not first then
				if tk.tag ~= "TComma" then
					self:unexpected(tk)
				else
					tk = self:token()
					if tk.tag == "TBkClose" then break end
				end
			end
			first = false
			self:push(tk)
			table.insert(a, self:parseExpr())
			tk = self:token()
		end

		if #a == 1 and a[1] then
			local at = a[1].tag
			if at == "EFor" or at == "EWhile" or at == "EDoWhile" then
				local tmp = "__a_" .. tostring(self.uid)
				self.uid = self.uid + 1
				local e = Expr.EBlock({
					Expr.EVar(tmp, nil, Expr.EArrayDecl({})),
					self:mapCompr(tmp, a[1]),
					Expr.EIdent(tmp),
				})
				return self:parseExprNext(e)
			end
		end

		return self:parseExprNext(Expr.EArrayDecl(a))
	end

	if tk.tag == "TMeta" and self.allowMetadata then
		local args = self:parseMetaArgs()
		return Expr.EMeta(tk.s, args, self:parseExpr())
	end

	return self:unexpected(tk)
end

function Parser:parseLambda(args, pmin)
	local _ = pmin
	while true do
		local id = self:getIdent()
		local t = self:maybe(tok("TDoubleDot")) and self:parseType() or nil
		table.insert(args, { name = id, t = t })
		local tk = self:token()
		if tk.tag == "TComma" then
            goto continue
		elseif tk.tag == "TPClose" then
			break
		else
			self:unexpected(tk)
			break
		end
	    ::continue::
	end
	self:ensureToken(tok("TOp", { s = "->" }))
	local eret = self:parseExpr()
	return Expr.EFunction(args, Expr.EReturn(eret))
end

function Parser:parseMetaArgs()
	local tk = self:token()
	if tk.tag ~= "TPOpen" then
		self:push(tk)
		return nil
	end
	local args = {}
	tk = self:token()
	if tk.tag ~= "TPClose" then
		self:push(tk)
		while true do
			table.insert(args, self:parseExpr())
			local t = self:token()
			if t.tag == "TComma" then
                goto continue
			elseif t.tag == "TPClose" then
				break
			else
				self:unexpected(t)
				break
			end
            ::continue::
		end
	end
	return args
end

function Parser:mapCompr(tmp, e)
	if e == nil then return nil end
	local tag = e.tag
	if tag == "EFor" then
		return Expr.EFor(e.v, e.it, self:mapCompr(tmp, e.e))
	elseif tag == "EForGen" then
		return Expr.EForGen(e.it, self:mapCompr(tmp, e.e))
	elseif tag == "EWhile" then
		return Expr.EWhile(e.cond, self:mapCompr(tmp, e.e))
	elseif tag == "EDoWhile" then
		return Expr.EDoWhile(e.cond, self:mapCompr(tmp, e.e))
	elseif tag == "EIf" and e.e2 == nil then
		return Expr.EIf(e.cond, self:mapCompr(tmp, e.e1), nil)
	elseif tag == "EBlock" and #e.e == 1 then
		return Expr.EBlock({ self:mapCompr(tmp, e.e[1]) })
	elseif tag == "EParent" then
		return Expr.EParent(self:mapCompr(tmp, e.e))
	end
	return Expr.ECall(Expr.EField(Expr.EIdent(tmp), "push"), { e })
end

function Parser:makeUnop(op, e)
	if e == nil and self.resumeErrors then return nil end
	if e and e.tag == "EBinop" then
		return Expr.EBinop(e.op, self:makeUnop(op, e.e1), e.e2)
	elseif e and e.tag == "ETernary" then
		return Expr.ETernary(self:makeUnop(op, e.cond), e.e1, e.e2)
	end
	return Expr.EUnop(op, true, e)
end

function Parser:makeBinop(op, e1, e)
	if e == nil and self.resumeErrors then return Expr.EBinop(op, e1, e) end
	if e and e.tag == "EBinop" then
		local p1 = self.opPriority[op] or 999
		local p2 = self.opPriority[e.op] or 999
		local delta = p1 - p2
		if delta < 0 or (delta == 0 and not self.opRightAssoc[op]) then
			return Expr.EBinop(e.op, self:makeBinop(op, e1, e.e1), e.e2)
		end
		return Expr.EBinop(op, e1, e)
	elseif e and e.tag == "ETernary" then
		if self.opRightAssoc[op] then
			return Expr.EBinop(op, e1, e)
		end
		return Expr.ETernary(self:makeBinop(op, e1, e.cond), e.e1, e.e2)
	end
	return Expr.EBinop(op, e1, e)
end

function Parser:parseStructure(id)
	if id == "if" then
		self:ensure(tok("TPOpen"))
		local cond = self:parseExpr()
		self:ensure(tok("TPClose"))
		local e1 = self:parseExpr()
		local e2 = nil
		local semic = false
		local tk = self:token()
		if tk.tag == "TSemicolon" then
			semic = true
			tk = self:token()
		end
		if tk.tag == "TId" and tk.s == "else" then
			e2 = self:parseExpr()
		else
			self:push(tk)
			if semic then self:push(tok("TSemicolon")) end
		end
		return Expr.EIf(cond, e1, e2)
	end

	if id == "var" or id == "final" then
		local ident = self:getIdent()
		local tk = self:token()
		local t = nil
		if tk.tag == "TDoubleDot" and self.allowTypes then
			t = self:parseType()
			tk = self:token()
		end
		local e = nil

		if tk.tag == "TOp" and tk.s == "=" then
			e = self:parseExpr()
		elseif tk.tag == "TOp" then
			self:unexpected(tk)
		elseif tk.tag == "TComma" or tk.tag == "TSemicolon" then
			self:push(tk)
		elseif t ~= nil then
			self:push(tk)
		else
			self:unexpected(tk)
		end

		if id == "var" then return Expr.EVar(ident, t, e) end
		return Expr.EFinal(ident, t, e)
	end

	if id == "while" then
		local econd = self:parseExpr()
		local e = self:parseExpr()
		return Expr.EWhile(econd, e)
	end

	if id == "do" then
		local e = self:parseExpr()
		local tk = self:token()
		if tk.tag ~= "TId" or tk.s ~= "while" then self:unexpected(tk) end
		local econd = self:parseExpr()
		return Expr.EDoWhile(econd, e)
	end

	if id == "for" then
		self:ensure(tok("TPOpen"))
		local eit = self:parseExpr()
		self:ensure(tok("TPClose"))
		local e = self:parseExpr()
		if eit and eit.tag == "EBinop" and eit.op == "in" and eit.e1 and eit.e1.tag == "EIdent" then
			return Expr.EFor(eit.e1.v, eit.e2, e)
		end
		return Expr.EForGen(eit, e)
	end

	if id == "break" then return Expr.EBreak() end
	if id == "continue" then return Expr.EContinue() end
	if id == "else" then return self:unexpected(tok("TId", { s = id })) end

	if id == "inline" then
		if not self:maybe(tok("TId", { s = "function" })) then
			self:unexpected(tok("TId", { s = "inline" }))
		end
		return self:parseStructure("function")
	end

	if id == "function" then
		local tk = self:token()
		local name = nil
		if tk.tag == "TId" then name = tk.s else self:push(tk) end
		local inf = self:parseFunctionDecl()
		return Expr.EFunction(inf.args, inf.body, name, inf.ret)
	end

	if id == "return" then
		local tk = self:token()
		self:push(tk)
		local e = (tk.tag == "TSemicolon") and nil or self:parseExpr()
		return Expr.EReturn(e)
	end

	if id == "new" then
		local a = { self:getIdent() }
		while true do
			local tk = self:token()
			if tk.tag == "TDot" then
				table.insert(a, self:getIdent())
			elseif tk.tag == "TPOpen" then
				break
			else
				self:unexpected(tk)
				break
			end
		end
		local args = self:parseExprList(tok("TPClose"))
		return Expr.ENew(table.concat(a, "."), args)
	end

	if id == "import" then
		local path = { self:getIdent() }
		local star = false
		while true do
			local t = self:token()
			if t.tag ~= "TDot" then
				self:push(t)
				break
			end

			t = self:token()
			if t.tag == "TId" then
				table.insert(path, t.s)
			elseif t.tag == "TOp" and t.s == "*" then
				star = true
				break
			else
				self:unexpected(t)
			end
		end

		local name = nil
		if self:maybe(tok("TId", { s = "as" })) and not star then
			local t = self:token()
			if t.tag == "TId" then
				name = t.s
			else
				self:unexpected(t)
			end
		end

		return Expr.EImport(table.concat(path, "."), star, name)
	end

	if id == "using" then
		local path = { self:getIdent() }
		while true do
			local t = self:token()
			if t.tag ~= "TDot" then
				self:push(t)
				break
			end

			local n = self:token()
			if n.tag == "TId" then
				table.insert(path, n.s)
			else
				self:unexpected(n)
			end
		end

		return Expr.EUsing(table.concat(path, "."))
	end

	if id == "class" then
		local name = self:getIdent()
		local extend = nil
		local fields = nil

		local tk = self:token()
		if tk.tag == "TId" and tk.s == "extends" then
			local path = { self:getIdent() }
			while true do
				local t = self:token()
				if t.tag ~= "TDot" then
					self:push(t)
					break
				end

				t = self:token()
				if t.tag == "TId" then
					table.insert(path, t.s)
				else
					self:unexpected(t)
				end
			end
			extend = table.concat(path, ".")
			tk = self:token()
		end

		if tk.tag == "TBrOpen" then
			fields = {}
			while not self:maybe(tok("TBrClose")) do
				table.insert(fields, self:parseField())
			end
			return Expr.EClassDeclFull(name, extend, fields)
		else
			self:push(tk)
			self:ensure(tok("TSemicolon"))
			return Expr.EClassDecl(name, extend)
		end
	end

	if id == "throw" then
		return Expr.EThrow(self:parseExpr())
	end

	if id == "try" then
		local e = self:parseExpr()
		self:ensureToken(tok("TId", { s = "catch" }))
		self:ensure(tok("TPOpen"))
		local vname = self:getIdent()
		local t = nil
		if self:maybe(tok("TDoubleDot")) then
			if self.allowTypes then
				t = self:parseType()
			else
				self:ensureToken(tok("TId", { s = "Dynamic" }))
			end
		end
		self:ensure(tok("TPClose"))
		local ec = self:parseExpr()
		return Expr.ETry(e, vname, t, ec)
	end

	if id == "switch" then
		local e = self:parseExpr()
		local def = nil
		local cases = {}
		self:ensure(tok("TBrOpen"))
		while true do
			local tk = self:token()
			if tk.tag == "TId" and tk.s == "case" then
				local c = { values = {}, expr = nil }
				table.insert(cases, c)
				while true do
					table.insert(c.values, self:parseExpr())
					tk = self:token()
					if tk.tag == "TComma" then
						goto next
					elseif tk.tag == "TDoubleDot" then
						break
					else
						self:unexpected(tk)
						break
					end
                    ::next::
				end

				local exprs = {}
				while true do
					tk = self:token()
					self:push(tk)
					if (tk.tag == "TId" and (tk.s == "case" or tk.s == "default")) or tk.tag == "TBrClose" then
						break
					elseif tk.tag == "TEof" and self.resumeErrors then
						break
					else
						self:parseFullExpr(exprs)
					end
				end

				if #exprs == 1 then
					c.expr = exprs[1]
				elseif #exprs == 0 then
					c.expr = Expr.EBlock({})
				else
					c.expr = Expr.EBlock(exprs)
				end
			elseif tk.tag == "TId" and tk.s == "default" then
				if def ~= nil then self:unexpected(tk) end
				self:ensure(tok("TDoubleDot"))
				local exprs = {}
				while true do
					tk = self:token()
					self:push(tk)
					if (tk.tag == "TId" and (tk.s == "case" or tk.s == "default")) or tk.tag == "TBrClose" then
						break
					elseif tk.tag == "TEof" and self.resumeErrors then
						break
					else
						self:parseFullExpr(exprs)
					end
				end
				if #exprs == 1 then
					def = exprs[1]
				elseif #exprs == 0 then
					def = Expr.EBlock({})
				else
					def = Expr.EBlock(exprs)
				end
			elseif tk.tag == "TBrClose" then
				break
			else
				self:unexpected(tk)
				break
			end
		end
		return Expr.ESwitch(e, cases, def)
	end

	return nil
end

function Parser:parseExprNext(e1)
	local tk = self:token()

	if tk.tag == "TOp" then
		local op = tk.s
		if op == "->" then
			if e1.tag == "EIdent" then
				local eret = self:parseExpr()
				return Expr.EFunction({ { name = e1.v } }, Expr.EReturn(eret))
			elseif e1.tag == "EParent" and e1.e and e1.e.tag == "EIdent" then
				local eret = self:parseExpr()
				return Expr.EFunction({ { name = e1.e.v } }, Expr.EReturn(eret))
			elseif e1.tag == "ECheckType" and e1.e and e1.e.tag == "EIdent" then
				local eret = self:parseExpr()
				return Expr.EFunction({ { name = e1.e.v, t = e1.t } }, Expr.EReturn(eret))
			end
			self:unexpected(tk)
		end

		if self.opPriority[op] == -1 then
			if self:isBlock(e1) or e1.tag == "EParent" then
				self:push(tk)
				return e1
			end
			return self:parseExprNext(Expr.EUnop(op, false, e1))
		end
		return self:makeBinop(op, e1, self:parseExpr())
	end

	if tk.tag == "TId" and self.opPriority[tk.s] ~= nil then
		return self:parseExprNext(self:makeBinop(tk.s, e1, self:parseExpr()))
	end

	if tk.tag == "TDot" then
		local field = self:getIdent()
		return self:parseExprNext(Expr.EField(e1, field))
	end

	if tk.tag == "TQuestionDot" then
		local field = self:getIdent()
		local tmp = "__a_" .. tostring(self.uid)
		self.uid = self.uid + 1

		local t = self:token()
		local function pushBack()
			self:push(t)
			return nil
		end

		local eOp = nil
		if t.tag == "TOp" then
			if not self.opRightAssoc[t.s] then eOp = pushBack() else eOp = t.s end
		elseif t.tag == "TPOpen" then
			eOp = ""
		else
			eOp = pushBack()
		end

		if eOp ~= nil and #eOp > 0 then
			local e2 = self:parseExpr()
			local e = Expr.EBlock({
				Expr.EVar(tmp, nil, e1),
				Expr.ETernary(
					Expr.EBinop("!=", Expr.EIdent(tmp), Expr.EIdent("null")),
					Expr.EBinop(eOp, Expr.EField(Expr.EIdent(tmp), field), e2),
					Expr.EIdent("null")
				)
			})
			return self:parseExprNext(e)
		end

		local thenExpr
		if eOp ~= nil and #eOp == 0 then
			thenExpr = Expr.ECall(Expr.EField(Expr.EIdent(tmp), field), self:parseExprList(tok("TPClose")))
		else
			thenExpr = Expr.EField(Expr.EIdent(tmp), field)
		end

		local e = Expr.EBlock({
			Expr.EVar(tmp, nil, e1),
			Expr.ETernary(
				Expr.EBinop("==", Expr.EIdent(tmp), Expr.EIdent("null")),
				Expr.EIdent("null"),
				thenExpr
			)
		})

		return self:parseExprNext(e)
	end

	if tk.tag == "TPOpen" then
		return self:parseExprNext(Expr.ECall(e1, self:parseExprList(tok("TPClose"))))
	end

	if tk.tag == "TBkOpen" then
		local e2 = self:parseExpr()
		self:ensure(tok("TBkClose"))
		return self:parseExprNext(Expr.EArray(e1, e2))
	end

	if tk.tag == "TQuestion" then
		local e2 = self:parseExpr()
		self:ensure(tok("TDoubleDot"))
		local e3 = self:parseExpr()
		return Expr.ETernary(e1, e2, e3)
	end

	self:push(tk)
	return e1
end

function Parser:parseFunctionArgs()
	local args = {}
	local tk = self:token()
	if tk.tag ~= "TPClose" then
		local done = false
		while not done do
			local name = nil
			local opt = false
			if tk.tag == "TQuestion" then
				opt = true
				tk = self:token()
			end
			if tk.tag == "TId" then
				name = tk.s
			else
				self:unexpected(tk)
				break
			end

			local arg = { name = name }
			if opt then arg.opt = true end
			table.insert(args, arg)

			if self.allowTypes then
				if self:maybe(tok("TDoubleDot")) then arg.t = self:parseType() end
				if self:maybe(tok("TOp", { s = "=" })) then arg.value = self:parseExpr() end
			end

			tk = self:token()
			if tk.tag == "TComma" then
				tk = self:token()
			elseif tk.tag == "TPClose" then
				done = true
			else
				self:unexpected(tk)
			end
		end
	end
	return args
end

function Parser:parseFunctionDecl()
	self:ensure(tok("TPOpen"))
	local args = self:parseFunctionArgs()
	local ret = nil
	if self.allowTypes then
		local tk = self:token()
		if tk.tag ~= "TDoubleDot" then
			self:push(tk)
		else
			ret = self:parseType()
		end
	end
	return { args = args, ret = ret, body = self:parseExpr() }
end

function Parser:parsePath()
	local path = { self:getIdent() }
	while true do
		local t = self:token()
		if t.tag ~= "TDot" then
			self:push(t)
			break
		end
		table.insert(path, self:getIdent())
	end
	return path
end

function Parser:parseType()
	local t = self:token()

	if t.tag == "TId" then
		self:push(t)
		local path = self:parsePath()
		local params = nil
		t = self:token()
		if t.tag == "TOp" and t.s == "<" then
			params = {}
			while true do
				local tk = self:token()
				if tk.tag == "TConst" then
					table.insert(params, CType.CTExpr(Expr.EConst(tk.c)))
				else
					self:push(tk)
					table.insert(params, self:parseType())
				end

				t = self:token()
				if t.tag == "TComma" then
					goto continue
				elseif t.tag == "TOp" then
					if t.s == ">" then
						break
					elseif #t.s > 0 and string.byte(t.s, 1) == string.byte(">") then
						local rest = t.s:sub(2)
						if #rest > 0 then
							table.insert(self.tokens, { t = tok("TOp", { s = rest }), min = self.tokenMin, max = self.tokenMax })
						end
						break
					else
						self:unexpected(t)
						break
					end
				else
					self:unexpected(t)
					break
				end

                ::continue::
			end
		else
			self:push(t)
		end

		return self:parseTypeNext(CType.CTPath(path, params))
	end

	if t.tag == "TPOpen" then
		local a = self:token()
		local b = self:token()
		self:push(b)
		self:push(a)

		local function withReturn(args)
			local tk = self:token()
			if not (tk.tag == "TOp" and tk.s == "->") then
				self:unexpected(tk)
			end
			return CType.CTFun(args, self:parseType())
		end

		if a.tag == "TPClose" or (a.tag == "TId" and b.tag == "TDoubleDot") then
			local args = {}
			for _, arg in ipairs(self:parseFunctionArgs()) do
				if arg.value ~= nil then
					self:error(Err.ECustom("Default values not allowed in function types"), self.tokenMin, self.tokenMax)
				end
				local at = arg.t
				if arg.opt then at = CType.CTOpt(at) end
				table.insert(args, CType.CTNamed(arg.name, at))
			end
			return withReturn(args)
		end

		local tt = self:parseType()
		local nextTk = self:token()
		if nextTk.tag == "TComma" then
			local args = { tt }
			while true do
				table.insert(args, self:parseType())
				if not self:maybe(tok("TComma")) then break end
			end
			self:ensure(tok("TPClose"))
			return withReturn(args)
		elseif nextTk.tag == "TPClose" then
			return self:parseTypeNext(CType.CTParent(tt))
		else
			return self:unexpected(nextTk)
		end
	end

	if t.tag == "TBrOpen" then
		local fields = {}
		local meta = nil
		while true do
			t = self:token()
			if t.tag == "TBrClose" then
				break
			elseif t.tag == "TId" and (t.s == "var" or t.s == "final") then
				local name = self:getIdent()
				self:ensure(tok("TDoubleDot"))
				if t.s == "final" then
					if meta == nil then meta = {} end
					table.insert(meta, { name = ":final", params = {} })
				end
				table.insert(fields, { name = name, t = self:parseType(), meta = meta })
				meta = nil
				self:ensure(tok("TSemicolon"))
			elseif t.tag == "TId" then
				local name = t.s
				self:ensure(tok("TDoubleDot"))
				table.insert(fields, { name = name, t = self:parseType(), meta = meta })
				t = self:token()
				if t.tag == "TComma" then
                    goto continue
				elseif t.tag == "TBrClose" then
					break
				else
					self:unexpected(t)
				end
			elseif t.tag == "TMeta" then
				if meta == nil then meta = {} end
				table.insert(meta, { name = t.s, params = self:parseMetaArgs() })
			else
				self:unexpected(t)
				break
			end

            ::continue::
		end
		return self:parseTypeNext(CType.CTAnon(fields))
	end

	return self:unexpected(t)
end

function Parser:parseTypeNext(t)
	local tk = self:token()
	if tk.tag ~= "TOp" or tk.s ~= "->" then
		self:push(tk)
		return t
	end
	local t2 = self:parseType()
	if t2.tag == "CTFun" then
		table.insert(t2.args, 1, t)
		return t2
	end
	return CType.CTFun({ t }, t2)
end

function Parser:parseExprList(etk)
	local args = {}
	local tk = self:token()
	if tokEq(tk, etk) then return args end
	self:push(tk)
	while true do
		table.insert(args, self:parseExpr())
		tk = self:token()
		if tk.tag == "TComma" then
			goto continue
		elseif tokEq(tk, etk) then
			break
		else
			self:unexpected(tk)
			break
		end
        ::continue::
	end
	return args
end

function Parser:parseModule(content, origin, position)
	self:initParser(origin or "hscript", position or 0)
	self.input = content or ""
	self.readPos = 1
	self.allowTypes = true
	self.allowMetadata = true
	local decls = {}
	while true do
		local tk = self:token()
		if tk.tag == "TEof" then break end
		self:push(tk)
		table.insert(decls, self:parseModuleDecl())
	end
	return decls
end

function Parser:parseMetadata()
	local meta = {}
	while true do
		local tk = self:token()
		if tk.tag == "TMeta" then
			table.insert(meta, { name = tk.s, params = self:parseMetaArgs() })
		else
			self:push(tk)
			break
		end
	end
	return meta
end

function Parser:parseParams()
	if self:maybe(tok("TOp", { s = "<" })) then
		self:error(Err.EInvalidOp("Unsupported class type parameters"), self:currentPos(), self:currentPos())
	end
	return {}
end

function Parser:parseModuleDecl()
	local meta = self:parseMetadata()
	local ident = self:getIdent()
	local isPrivate = false
	local isExtern = false

	while true do
		if ident == "private" then
			isPrivate = true
		elseif ident == "extern" then
			isExtern = true
		else
			break
		end
		ident = self:getIdent()
	end

	if ident == "package" then
		local path = self:parsePath()
		self:ensure(tok("TSemicolon"))
		return { tag = "DPackage", path = path }
	end

	if ident == "import" then
		local path = { self:getIdent() }
		local star = false
		while true do
			local t = self:token()
			if t.tag ~= "TDot" then
				self:push(t)
				break
			end
			t = self:token()
			if t.tag == "TId" then
				table.insert(path, t.s)
			elseif t.tag == "TOp" and t.s == "*" then
				star = true
			else
				self:unexpected(t)
			end
		end
		local name = nil
		if self:maybe(tok("TId", { s = "as" })) and not star then
			local t = self:token()
			if t.tag == "TId" then name = t.s else self:unexpected(t) end
		end
		self:ensure(tok("TSemicolon"))
		return { tag = "DImport", path = path, star = star, name = name }
	end

	if ident == "using" then
		local path = { self:getIdent() }
		while true do
			local t = self:token()
			if t.tag ~= "TDot" then
				self:push(t)
				break
			end
			local n = self:token()
			if n.tag == "TId" then
				table.insert(path, n.s)
			else
				self:unexpected(n)
			end
		end
		self:ensure(tok("TSemicolon"))
		return { tag = "DUsing", path = path }
	end

	if ident == "class" then
		local name = self:getIdent()
		local params = self:parseParams()
		local extend = nil
		local implement = {}

		while true do
			local t = self:token()
			if t.tag == "TId" and t.s == "extends" then
				extend = self:parseType()
			elseif t.tag == "TId" and t.s == "implements" then
				table.insert(implement, self:parseType())
			else
				self:push(t)
				break
			end
		end

		local fields = {}
		self:ensure(tok("TBrOpen"))
		while not self:maybe(tok("TBrClose")) do
			table.insert(fields, self:parseField())
		end

		return {
			tag = "DClass",
			decl = {
				name = name,
				meta = meta,
				params = params,
				extend = extend,
				implement = implement,
				fields = fields,
				isPrivate = isPrivate,
				isExtern = isExtern,
			}
		}
	end

	if ident == "typedef" then
		local name = self:getIdent()
		local params = self:parseParams()
		self:ensureToken(tok("TOp", { s = "=" }))
		local t = self:parseType()
		return {
			tag = "DTypedef",
			decl = {
				name = name,
				meta = meta,
				params = params,
				isPrivate = isPrivate,
				t = t,
			}
		}
	end

	if ident == "enum" then
		local name = self:getIdent()
		local fields = {}
		self:ensure(tok("TBrOpen"))
		while not self:maybe(tok("TBrClose")) do
			table.insert(fields, self:parseEnumField())
			self:ensure(tok("TSemicolon"))
		end
		return { tag = "DEnum", decl = { name = name, fields = fields } }
	end

	self:unexpected(tok("TId", { s = ident }))
	return nil
end

function Parser:parseField()
	local meta = self:parseMetadata()
	local access = {}
	while true do
		local id = self:getIdent()
		if id == "override" then
			table.insert(access, "AOverride")
		elseif id == "public" then
			table.insert(access, "APublic")
		elseif id == "private" then
			table.insert(access, "APrivate")
		elseif id == "inline" then
			table.insert(access, "AInline")
		elseif id == "static" then
			table.insert(access, "AStatic")
		elseif id == "macro" then
			table.insert(access, "AMacro")
		elseif id == "function" then
			local name = self:getIdent()
			local inf = self:parseFunctionDecl()
			return {
				name = name,
				meta = meta,
				access = access,
				kind = {
					tag = "KFunction",
					f = { args = inf.args, expr = inf.body, ret = inf.ret }
				}
			}
		elseif id == "var" or id == "final" then
			local name = self:getIdent()
			local get, set = nil, nil
			if self:maybe(tok("TPOpen")) then
				get = self:getIdent()
				self:ensure(tok("TComma"))
				set = self:getIdent()
				self:ensure(tok("TPClose"))
			end
			local t = self:maybe(tok("TDoubleDot")) and self:parseType() or nil
			local e = self:maybe(tok("TOp", { s = "=" })) and self:parseExpr() or nil

			if e ~= nil then
				if self:isBlock(e) then self:maybe(tok("TSemicolon")) else self:ensure(tok("TSemicolon")) end
			elseif t ~= nil and t.tag == "CTAnon" then
				self:maybe(tok("TSemicolon"))
			else
				self:ensure(tok("TSemicolon"))
			end

			return {
				name = name,
				meta = meta,
				access = access,
				kind = {
					tag = "KVar",
					v = {
						get = get,
						set = set,
						type = t,
						expr = e,
						isfinal = id == "final",
					}
				}
			}
		else
			self:unexpected(tok("TId", { s = id }))
			break
		end
	end
	return nil
end

function Parser:parseEnumField()
	local name = self:getIdent()
	local args = {}
	if self:maybe(tok("TPOpen")) then
		while not self:maybe(tok("TPClose")) do
			table.insert(args, self:parseEnumArg())
		end
	end
	return { name = name, args = args }
end

function Parser:parseEnumArg()
	local name = self:getIdent()
	local t = self:maybe(tok("TDoubleDot")) and self:parseType() or nil
	return { name = name, type = t }
end

function Parser:readChar()
	local c = string.byte(self.input, self.readPos)
	self.readPos = self.readPos + 1
	if c == nil then return -1 end
	return c
end

function Parser:readString(ut)
	local b = {}
	local esc = false
	local old = self.line
	local p1 = self:currentPos() - 1

	while true do
		local c = self:readChar()
		if eofChar(c) then
			self.line = old
			self:error(Err.EUnterminatedString(), p1, p1)
			break
		end
		if esc then
			esc = false
			if c == string.byte("n") then
				b[#b + 1] = "\n"
			elseif c == string.byte("r") then
				b[#b + 1] = "\r"
			elseif c == string.byte("t") then
				b[#b + 1] = "\t"
			elseif c == string.byte("'") or c == string.byte('"') or c == string.byte("\\") then
				b[#b + 1] = string.char(c)
			elseif c == string.byte("/") then
				if self.allowJSON then b[#b + 1] = "/" else self:invalidChar(c) end
			elseif c == string.byte("u") then
				if not self.allowJSON then self:invalidChar(c) end
				local k = 0
				for _ = 1, 4 do
					k = k * 16
					local ch = self:readChar()
					if ch >= 48 and ch <= 57 then
						k = k + ch - 48
					elseif ch >= 65 and ch <= 70 then
						k = k + ch - 55
					elseif ch >= 97 and ch <= 102 then
						k = k + ch - 87
					else
						if eofChar(ch) then
							self.line = old
							self:error(Err.EUnterminatedString(), p1, p1)
						end
						self:invalidChar(ch)
					end
				end
				b[#b + 1] = utf8.char(k)
			else
				self:invalidChar(c)
			end
		elseif c == string.byte("\\") then
			esc = true
		elseif c == ut then
			break
		else
			if c == 10 then self.line = self.line + 1 end
			b[#b + 1] = string.char(c)
		end
	end
	return table.concat(b)
end

function Parser:token()
	local t = listPop(self.tokens)
	if t ~= nil then
		self.tokenMin = t.min
		self.tokenMax = t.max
		return t.t
	end

	self.oldTokenMin = self.tokenMin
	self.oldTokenMax = self.tokenMax
	self.tokenMin = (self.char < 0) and self:currentPos() or (self:currentPos() - 1)

	local tk = self:_token()
	self.tokenMax = (self.char < 0) and (self:currentPos() - 1) or (self:currentPos() - 2)

	return tk
end

function Parser:tokenComment(op, char)
	local c = string.byte(op, 2)
	if c == string.byte("/") then
		while char ~= string.byte("\r") and char ~= string.byte("\n") do
			char = self:readChar()
			if eofChar(char) then break end
		end
		self.char = char
		return self:token()
	end

	if c == string.byte("*") then
		local old = self.line
		if op == "/**/" then
			self.char = char
			return self:token()
		end
		while true do
			while char ~= string.byte("*") do
				if char == string.byte("\n") then self.line = self.line + 1 end
				char = self:readChar()
				if eofChar(char) then
					self.line = old
					self:error(Err.EUnterminatedComment(), self.tokenMin, self.tokenMin)
					break
				end
			end
			char = self:readChar()
			if eofChar(char) then
				self.line = old
				self:error(Err.EUnterminatedComment(), self.tokenMin, self.tokenMin)
				break
			end
			if char == string.byte("/") then break end
		end
		return self:token()
	end

	self.char = char
	return tok("TOp", { s = op })
end

function Parser:preprocValue(id)
	return self.preprocesorValues[id]
end

function Parser:parsePreproCond()
	local tk = self:token()
	if tk.tag == "TPOpen" then
		self:push(tok("TPOpen"))
		return self:parseExpr()
	elseif tk.tag == "TId" then
		return Expr.EIdent(tk.s)
	elseif tk.tag == "TOp" and tk.s == "!" then
		return Expr.EUnop("!", true, self:parsePreproCond())
	end
	return self:unexpected(tk)
end

function Parser:evalPreproCond(e)
	if not e then return false end
	local tag = e.tag
	if tag == "EIdent" then
		return self:preprocValue(e.v) ~= nil
	elseif tag == "EUnop" and e.op == "!" then
		return not self:evalPreproCond(e.e)
	elseif tag == "EParent" then
		return self:evalPreproCond(e.e)
	elseif tag == "EBinop" and e.op == "&&" then
		return self:evalPreproCond(e.e1) and self:evalPreproCond(e.e2)
	elseif tag == "EBinop" and e.op == "||" then
		return self:evalPreproCond(e.e1) or self:evalPreproCond(e.e2)
	end
	self:error(Err.EInvalidPreprocessor("Can't eval " .. tostring(tag)), self:currentPos(), self:currentPos())
	return false
end

function Parser:skipTokens()
	local spos = #self.preprocStack
	local obj = self.preprocStack[spos]
	local pos = self:currentPos()
	while true do
		local tk = self:token()
		if tk.tag == "TEof" then self:error(Err.EInvalidPreprocessor("Unclosed"), pos, pos) end
		if self.preprocStack[spos] ~= obj then
			self:push(tk)
			break
		end
	end
end

function Parser:preprocess(id)
	if id == "if" then
		local e = self:parsePreproCond()
		if self:evalPreproCond(e) then
			table.insert(self.preprocStack, { r = true })
			return self:token()
		end
		table.insert(self.preprocStack, { r = false })
		self:skipTokens()
		return self:token()
	elseif (id == "else" or id == "elseif") and #self.preprocStack > 0 then
		local top = self.preprocStack[#self.preprocStack]
		if top.r then
			top.r = false
			self:skipTokens()
			return self:token()
		elseif id == "else" then
			table.remove(self.preprocStack)
			table.insert(self.preprocStack, { r = true })
			return self:token()
		else
			table.remove(self.preprocStack)
			return self:preprocess("if")
		end
	elseif id == "end" and #self.preprocStack > 0 then
		table.remove(self.preprocStack)
		return self:token()
	end

	return tok("TPrepro", { s = id })
end

function Parser:_token()
	local char
	if self.char < 0 then
		char = self:readChar()
	else
		char = self.char
		self.char = -1
	end

	while true do
		if eofChar(char) then
			self.char = char
			return tok("TEof")
		end

		if char == 0 then
			return tok("TEof")
		elseif char == 32 or char == 9 or char == 13 then -- this is wghiutespace
		elseif char == 10 then
			self.line = self.line + 1

		elseif char >= 48 and char <= 57 then
			local n = (char - 48) * 1.0
			local exp = 0.0
			while true do
				char = self:readChar()
				exp = exp * 10
				if char >= 48 and char <= 57 then
					n = n * 10 + (char - 48)
				elseif char == string.byte("e") or char == string.byte("E") then
					local tk = self:token()
					local pow = nil
					if tk.tag == "TConst" and tk.c.tag == "CInt" then
						pow = tk.c.v
					elseif tk.tag == "TOp" and tk.s == "-" then
						tk = self:token()
						if tk.tag == "TConst" and tk.c.tag == "CInt" then
							pow = -tk.c.v
						else
							self:push(tk)
						end
					else
						self:push(tk)
					end

					if pow == nil then self:invalidChar(char) end
					if exp == 0 then exp = 10 end
					return tok("TConst", { c = Const.CFloat((10 ^ pow / exp) * n * 10) })
				elseif char == string.byte(".") then
					if exp > 0 then
						if exp == 10 then
							local c2 = self:readChar()
							if c2 == string.byte(".") then
								self:push(tok("TOp", { s = "..." }))
								local i = toInt(n)
								if i == n then
									return tok("TConst", { c = Const.CInt(i) })
								end
								return tok("TConst", { c = Const.CFloat(n) })
							end
							self.char = c2
						end
						self:invalidChar(char)
					end
					exp = 1.0
				elseif char == string.byte("x") then
					if n > 0 or exp > 0 then self:invalidChar(char) end
					local hn = 0
					while true do
						char = self:readChar()
						if char >= 48 and char <= 57 then
							hn = bit.lshift(hn, 4) + (char - 48)
						elseif char >= 65 and char <= 70 then
							hn = bit.lshift(hn, 4) + (char - 55)
						elseif char >= 97 and char <= 102 then
							hn = bit.lshift(hn, 4) + (char - 87)
						else
							self.char = char
							return tok("TConst", { c = Const.CInt(hn) })
						end
					end
				else
					self.char = char
					local i = toInt(n)
					if exp > 0 then
						return tok("TConst", { c = Const.CFloat(n * 10 / exp) })
					elseif i == n then
						return tok("TConst", { c = Const.CInt(i) })
					else
						return tok("TConst", { c = Const.CFloat(n) })
					end
				end
			end

		elseif char == string.byte(";") then
			return tok("TSemicolon")
		elseif char == string.byte("(") then
			return tok("TPOpen")
		elseif char == string.byte(")") then
			return tok("TPClose")
		elseif char == string.byte(",") then
			return tok("TComma")
		elseif char == string.byte(".") then
			char = self:readChar()
			if char >= 48 and char <= 57 then
				local n = char - 48
				local exp = 1
				while true do
					char = self:readChar()
					exp = exp * 10
					if char >= 48 and char <= 57 then
						n = n * 10 + (char - 48)
					else
						self.char = char
						return tok("TConst", { c = Const.CFloat(n / exp) })
					end
				end
			elseif char == string.byte(".") then
				char = self:readChar()
				if char ~= string.byte(".") then self:invalidChar(char) end
				return tok("TOp", { s = "..." })
			else
				self.char = char
				return tok("TDot")
			end

		elseif char == string.byte("{") then
			return tok("TBrOpen")
		elseif char == string.byte("}") then
			return tok("TBrClose")
		elseif char == string.byte("[") then
			return tok("TBkOpen")
		elseif char == string.byte("]") then
			return tok("TBkClose")
		elseif char == string.byte("'") or char == string.byte('"') then
			return tok("TConst", { c = Const.CString(self:readString(char)) })
		elseif char == string.byte("?") then
			char = self:readChar()
			if char == string.byte(".") then
				return tok("TQuestionDot")
			elseif char == string.byte("?") then
				char = self:readChar()
				if char == string.byte("=") then return tok("TOp", { s = "??=" }) end
				self.char = char
				return tok("TOp", { s = "??" })
			end
			self.char = char
			return tok("TQuestion")
		elseif char == string.byte(":") then
			return tok("TDoubleDot")
		elseif char == string.byte("=") then
			char = self:readChar()
			if char == string.byte("=") then
				return tok("TOp", { s = "==" })
			elseif char == string.byte(">") then
				return tok("TOp", { s = "=>" })
			end
			self.char = char
			return tok("TOp", { s = "=" })
		elseif char == string.byte("@") then
			char = self:readChar()
			if self.idents[char] or char == string.byte(":") then
				local out = { string.char(char) }
				while true do
					char = self:readChar()
					if not self.idents[char] then
						self.char = char
						return tok("TMeta", { s = table.concat(out) })
					end
					out[#out + 1] = string.char(char)
				end
			end
			self:invalidChar(char)
		elseif char == string.byte("#") then
			char = self:readChar()
			if self.idents[char] then
				local out = { string.char(char) }
				while true do
					char = self:readChar()
					if not self.idents[char] then
						self.char = char
						return self:preprocess(table.concat(out))
					end
					out[#out + 1] = string.char(char)
				end
			end
			self:invalidChar(char)
		else
			if self.ops[char] then
				local op = { string.char(char) }
				while true do
					char = self:readChar()
					if eofChar(char) then char = 0 end
					if not self.ops[char] then
						self.char = char
						return tok("TOp", { s = table.concat(op) })
					end
					local pop = table.concat(op)
					op[#op + 1] = string.char(char)
					local full = table.concat(op)
					if self.opPriority[full] == nil and self.opPriority[pop] ~= nil then
						if full == "//" or full == "/*" then
							return self:tokenComment(full, char)
						end
						self.char = char
						return tok("TOp", { s = pop })
					end
				end
			elseif self.idents[char] then
				local id = { string.char(char) }
				while true do
					char = self:readChar()
					if eofChar(char) then char = 0 end
					if not self.idents[char] then
						self.char = char
						return tok("TId", { s = table.concat(id) })
					end
					id[#id + 1] = string.char(char)
				end
			end
			self:invalidChar(char)
		end

		char = self:readChar()
	end
end

function Parser:constString(c)
	if c.tag == "CInt" then return tostring(c.v) end
	if c.tag == "CFloat" then return tostring(c.f) end
	if c.tag == "CString" then return c.s end
	return "?"
end

function Parser:tokenString(t)
	local tag = t and t.tag or "<nil>"
	if tag == "TEof" then return "<eof>" end
	if tag == "TConst" then return self:constString(t.c) end
	if tag == "TId" then return t.s end
	if tag == "TOp" then return t.s end
	if tag == "TPOpen" then return "(" end
	if tag == "TPClose" then return ")" end
	if tag == "TBrOpen" then return "{" end
	if tag == "TBrClose" then return "}" end
	if tag == "TDot" then return "." end
	if tag == "TQuestionDot" then return "?." end
	if tag == "TComma" then return "," end
	if tag == "TSemicolon" then return ";" end
	if tag == "TBkOpen" then return "[" end
	if tag == "TBkClose" then return "]" end
	if tag == "TQuestion" then return "?" end
	if tag == "TDoubleDot" then return ":" end
	if tag == "TMeta" then return "@" .. t.s end
	if tag == "TPrepro" then return "#" .. t.s end
	return "<unknown token>"
end

return Parser
