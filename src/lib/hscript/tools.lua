local Tools = {}

function Tools.expr(e)
    return e
end

function Tools.iter(e, f)
    local tag = e.tag

    if tag == "EConst" or tag == "EIdent" then
        return
    elseif tag == "EVar" or tag == "EFinal" then
        if e.e then f(e.e) end
    elseif tag == "EParent" then
        f(e.e)
    elseif tag == "EBlock" then
        for _,ex in ipairs(e.e) do
            f(ex)
        end
    elseif tag == "EField" then
        f(e.e)
    elseif tag == "EBinop" then
        f(e.e1)
        f(e.e2)
    elseif tag == "EUnop" then
        f(e.e)
    elseif tag == "ECall" then
        f(e.e)
        for _,a in ipairs(e.params) do
            f(a)
        end
    elseif tag == "EIf" then
        f(e.cond)
        f(e.e1)
        if e.e2 then f(e.e2) end
    elseif tag == "EWhile" or tag == "EDoWhile" then
        f(e.cond)
        f(e.e)
    elseif tag == "EFor" then
        f(e.it)
        f(e.e)
    elseif tag == "EForGen" then
        f(e.it)
        f(e.e)
    elseif tag == "EBreak" or tag == "EContinue" then
        return
    elseif tag == "EFunction" then
        f(e.e)
    elseif tag == "EReturn" then
        if e.e then f(e.e) end
    elseif tag == "EArray" then
        f(e.e)
        f(e.index)
    elseif tag == "EArrayDecl" then
        for _,ex in ipairs(e.e) do
            f(ex)
        end
    elseif tag == "ENew" then
        for _,ex in ipairs(e.params) do
            f(ex)
        end
    elseif tag == "EThrow" then
        f(e.e)
    elseif tag == "ETry" then
        f(e.e)
        f(e.ecatch)
    elseif tag == "EObject" then
        for _,fi in ipairs(e.fl) do
            f(fi.e)
        end
    elseif tag == "ETernary" then
        f(e.cond)
        f(e.e1)
        f(e.e2)
    elseif tag == "ESwitch" then
        f(e.e)

        for _,c in ipairs(e.cases) do
            for _,v in ipairs(c.values) do
                f(v)
            end
            f(c.expr)
        end

        if e.defaultExpr then
            f(e.defaultExpr)
        end
    elseif tag == "EMeta" then
        if e.args then
            for _,a in ipairs(e.args) do
                f(a)
            end
        end

        f(e.e)
    elseif tag == "ECheckType" then
        f(e.e)
    end
end

function Tools.map(e, f)
    local tag = e.tag
    local edef

    if tag == "EConst" or tag == "EIdent" or tag == "EBreak" or tag == "EContinue" then
        edef = e
    elseif tag == "EVar" then
        edef = {
            tag="EVar",
            n=e.n,
            t=e.t,
            e = e.e and f(e.e) or nil
        }
    elseif tag == "EFinal" then
        edef = {
            tag="EFinal",
            n=e.n,
            t=e.t,
            e = e.e and f(e.e) or nil
        }
    elseif tag == "EParent" then
        edef = { tag="EParent", e=f(e.e) }
    elseif tag == "EBlock" then
        local el={}
        for _,v in ipairs(e.e) do
            el[#el+1] = f(v)
        end
        edef = { tag="EBlock", e=el }
    elseif tag == "EField" then
        edef = { tag="EField", e=f(e.e), f=e.f }
    elseif tag == "EBinop" then
        edef = { tag="EBinop", op=e.op, e1=f(e.e1), e2=f(e.e2) }
    elseif tag == "EUnop" then
        edef = { tag="EUnop", op=e.op, prefix=e.prefix, e=f(e.e) }
    elseif tag == "ECall" then
        local args={}
        for _,a in ipairs(e.params) do
            args[#args+1] = f(a)
        end
        edef = { tag="ECall", e=f(e.e), params=args }
    elseif tag == "EIf" then
        edef = {
            tag="EIf",
            cond=f(e.cond),
            e1=f(e.e1),
            e2=e.e2 and f(e.e2) or nil
        }
    elseif tag == "EWhile" then
        edef = { tag="EWhile", cond=f(e.cond), e=f(e.e) }
    elseif tag == "EDoWhile" then
        edef = { tag="EDoWhile", cond=f(e.cond), e=f(e.e) }
    elseif tag == "EFor" then
        edef = { tag="EFor", v=e.v, it=f(e.it), e=f(e.e) }
    elseif tag == "EForGen" then
        edef = { tag="EForGen", it=f(e.it), e=f(e.e) }
    elseif tag == "EFunction" then
        edef = { tag="EFunction", args=e.args, e=f(e.e), name=e.name, ret=e.ret }
    elseif tag == "EReturn" then
        edef = { tag="EReturn", e=e.e and f(e.e) or nil }
    elseif tag == "EArray" then
        edef = { tag="EArray", e=f(e.e), index=f(e.index) }
    elseif tag == "EArrayDecl" then
        local el={}
        for _,v in ipairs(e.e) do
            el[#el+1]=f(v)
        end
        edef = { tag="EArrayDecl", e=el }
    elseif tag == "ENew" then
        local el={}
        for _,v in ipairs(e.params) do
            el[#el+1]=f(v)
        end
        edef = { tag="ENew", cl=e.cl, params=el }
    elseif tag == "EThrow" then
        edef = { tag="EThrow", e=f(e.e) }
    elseif tag == "ETry" then
        edef = { tag="ETry", e=f(e.e), v=e.v, t=e.t, ecatch=f(e.ecatch) }
    elseif tag == "EObject" then
        local fl={}
        for _,fi in ipairs(e.fl) do
            fl[#fl+1] = { name=fi.name, e=f(fi.e) }
        end
        edef = { tag="EObject", fl=fl }
    elseif tag == "ETernary" then
        edef = { tag="ETernary", cond=f(e.cond), e1=f(e.e1), e2=f(e.e2) }
    elseif tag == "ESwitch" then
        local cases={}
        for _,c in ipairs(e.cases) do
            local vals={}
            for _,v in ipairs(c.values) do
                vals[#vals+1] = f(v)
            end
            cases[#cases+1] = { values=vals, expr=f(c.expr) }
        end

        edef = {
            tag="ESwitch",
            e=f(e.e),
            cases=cases,
            defaultExpr=e.defaultExpr and f(e.defaultExpr) or nil
        }
    elseif tag == "EMeta" then
        local args=nil
        if e.args then
            args={}
            for _,a in ipairs(e.args) do
                args[#args+1] = f(a)
            end
        end

        edef = { tag="EMeta", name=e.name, args=args, e=f(e.e) }
    elseif tag == "ECheckType" then
        edef = { tag="ECheckType", e=f(e.e), t=e.t }
    end

    return edef
end

function Tools.getKeyIterator(e, callb)
    local key=nil
    local value=nil
    local it=e

    if e.tag=="EBinop" and e.op=="in" then
        local ekv=e.e1
        local eiter=e.e2

        if ekv.tag=="EBinop" and ekv.op=="=>" then
            local v1=ekv.e1
            local v2=ekv.e2

            if v1.tag=="EIdent" and v2.tag=="EIdent" then
                key=v1.v
                value=v2.v
                it=eiter
            end
        end
    end

    return callb(key,value,it)
end

return Tools