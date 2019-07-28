local defTypeMt = {
    __index = {}
}

local defType   = setmetatable({ types = {} }, defTypeMt)

function defTypeMt.__call()
    local builderMt = { __index = {} }

    function builderMt.__index:typeMethod(name, code)
        self.typeMethods[name] = code
        return self
    end

    function builderMt.__index:boundTypeMethod(name, code)
        self.boundTypeMethods[name] = code
        return self
    end

    function builderMt.__index:instanceMethod(name, code)
        self.instanceMethods[name] = code
        return self
    end

    function builderMt.__index:build()
        local type
        local typeMt = { __index = self.typeMethods }

        for name, code in pairs(self.boundTypeMethods) do
            self.typeMethods[name] = function(...) return code(type, ...) end
        end

        type = setmetatable({ __index = self.instanceMethods }, typeMt)

        function typeMt.__call(self, base)
            return setmetatable(base or {}, type)
        end

        table.insert(defType.types, type)

        return type
    end

    return setmetatable({ typeMethods = {}, boundTypeMethods = {}, instanceMethods = {} }, builderMt)
end

function defTypeMt.__index.recognizesInstance(value)
    if type(value) ~= 'table' then
        return false
    end

    local mt1 = getmetatable(value)

    for _, mt2 in ipairs(defType.types) do
        if mt1 == mt2 then
            return true
        end
    end

    return false
end

return defType
