local curdir = (...):match("(.-)[^%.]+$")
local class = require(curdir .. "class")

local AST = {}

AST.Const = {}

function AST.Const.CInt(v)
    return { tag = "CInt", v = v }
end

function AST.Const.CFloat(f)
    return { tag = "CFloat", f = f }
end

function AST.Const.CString(s)
    return { tag = "CString", s = s }
end

AST.Expr = {}

function AST.Expr.EConst(c)
    return { tag = "EConst", c = c }
end

function AST.Expr.EIdent(v)
    return { tag = "EIdent", v = v }
end

function AST.Expr.EVar(n, t, e)
    return { tag = "EVar", n = n, t = t, e = e }
end

function AST.Expr.EFinal(n, t, e)
    return { tag = "EFinal", n = n, t = t, e = e }
end

function AST.Expr.EParent(e)
    return { tag = "EParent", e = e }
end

function AST.Expr.EBlock(e)
    return { tag = "EBlock", e = e }
end

function AST.Expr.EField(e, f)
    return { tag = "EField", e = e, f = f }
end

function AST.Expr.EBinop(op, e1, e2)
    return { tag = "EBinop", op = op, e1 = e1, e2 = e2 }
end

function AST.Expr.EUnop(op, prefix, e)
    return { tag = "EUnop", op = op, prefix = prefix, e = e }
end

function AST.Expr.ECall(e, params)
    return { tag = "ECall", e = e, params = params }
end

function AST.Expr.EIf(cond, e1, e2)
    return { tag = "EIf", cond = cond, e1 = e1, e2 = e2 }
end

function AST.Expr.EWhile(cond, e)
    return { tag = "EWhile", cond = cond, e = e }
end

function AST.Expr.EFor(v, it, e)
    return { tag = "EFor", v = v, it = it, e = e }
end

function AST.Expr.EBreak()
    return { tag = "EBreak" }
end

function AST.Expr.EContinue()
    return { tag = "EContinue" }
end

function AST.Expr.EFunction(args, e, name, ret)
    return { tag = "EFunction", args = args, e = e, name = name, ret = ret }
end

function AST.Expr.EReturn(e)
    return { tag = "EReturn", e = e }
end

function AST.Expr.EArray(e, index)
    return { tag = "EArray", e = e, index = index }
end

function AST.Expr.EArrayDecl(e)
    return { tag = "EArrayDecl", e = e }
end

function AST.Expr.ENew(cl, params)
    return { tag = "ENew", cl = cl, params = params }
end

function AST.Expr.EThrow(e)
    return { tag = "EThrow", e = e }
end

function AST.Expr.ETry(e, v, t, ecatch)
    return { tag = "ETry", e = e, v = v, t = t, ecatch = ecatch }
end

function AST.Expr.EObject(fl)
    return { tag = "EObject", fl = fl }
end

function AST.Expr.ETernary(cond, e1, e2)
    return { tag = "ETernary", cond = cond, e1 = e1, e2 = e2 }
end

function AST.Expr.ESwitch(e, cases, defaultExpr)
    return { tag = "ESwitch", e = e, cases = cases, defaultExpr = defaultExpr }
end

function AST.Expr.EDoWhile(cond, e)
    return { tag = "EDoWhile", cond = cond, e = e }
end

function AST.Expr.EMeta(name, args, e)
    return { tag = "EMeta", name = name, args = args, e = e }
end

function AST.Expr.ECheckType(e, t)
    return { tag = "ECheckType", e = e, t = t }
end

function AST.Expr.EForGen(it, e)
    return { tag = "EForGen", it = it, e = e }
end

function AST.Expr.EImport(path, star, name)
    return { tag = "EImport", path = path, star = star, name = name }
end

function AST.Expr.EUsing(path)
    return { tag = "EUsing", path = path }
end

function AST.Expr.EClassDecl(name, extend)
    return { tag = "EClassDecl", name = name, extend = extend }
end

function AST.Expr.EClassDeclFull(name, extend, fields)
    return { tag = "EClassDeclFull", name = name, extend = extend, fields = fields }
end

AST.CType = {}

function AST.CType.CTPath(path, params)
    return { tag = "CTPath", path = path, params = params }
end

function AST.CType.CTFun(args, ret)
    return { tag = "CTFun", args = args, ret = ret }
end

function AST.CType.CTAnon(fields)
    return { tag = "CTAnon", fields = fields }
end

function AST.CType.CTParent(t)
    return { tag = "CTParent", t = t }
end

function AST.CType.CTOpt(t)
    return { tag = "CTOpt", t = t }
end

function AST.CType.CTNamed(n, t)
    return { tag = "CTNamed", n = n, t = t }
end

function AST.CType.CTExpr(e)
    return { tag = "CTExpr", e = e }
end

AST.Error = {}

function AST.Error.EInvalidChar(c)
    return { tag = "EInvalidChar", c = c }
end

function AST.Error.EUnexpected(s)
    return { tag = "EUnexpected", s = s }
end

function AST.Error.EUnterminatedString()
    return { tag = "EUnterminatedString" }
end

function AST.Error.EUnterminatedComment()
    return { tag = "EUnterminatedComment" }
end

function AST.Error.EInvalidPreprocessor(msg)
    return { tag = "EInvalidPreprocessor", msg = msg }
end

function AST.Error.EUnknownVariable(v)
    return { tag = "EUnknownVariable", v = v }
end

function AST.Error.EInvalidIterator(v)
    return { tag = "EInvalidIterator", v = v }
end

function AST.Error.EInvalidOp(op)
    return { tag = "EInvalidOp", op = op }
end

function AST.Error.EInvalidAccess(f)
    return { tag = "EInvalidAccess", f = f }
end

function AST.Error.ECustom(msg)
    return { tag = "ECustom", msg = msg }
end

AST.ClassDecl = class:extend("ClassDecl")

function AST.ClassDecl:new()
    self.name = nil
    self.params = {}
    self.meta = {}
    self.isPrivate = false

    self.extend = nil
    self.implement = {}
    self.fields = {}
    self.isExtern = false
end

AST.EnumDecl = class:extend("EnumDecl")

function AST.EnumDecl:new()
    self.name = nil
    self.fields = {}
end

AST.TypeDecl = class:extend("TypeDecl")

function AST.TypeDecl:new()
    self.name = nil
    self.params = {}
    self.meta = {}
    self.isPrivate = false

    self.t = nil
end

AST.FieldDecl = class:extend("FieldDecl")

function AST.FieldDecl:new()
    self.name = nil
    self.meta = {}
    self.kind = nil
    self.access = {}
end

AST.FunctionDecl = class:extend("FunctionDecl")

function AST.FunctionDecl:new()
    self.args = {}
    self.expr = nil
    self.ret = nil
end

AST.VarDecl = class:extend("VarDecl")

function AST.VarDecl:new()
    self.get = nil
    self.set = nil
    self.expr = nil
    self.type = nil
    self.isfinal = nil
end

return AST