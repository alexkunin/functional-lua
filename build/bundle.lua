local args = { ... }

return (function()
    local modules

    local package --= _G.package

    if package == nil then
        package = {}
    end

    if package.loaded == nil then
        package.loaded = {}
    end

    if package.loaders == nil then
        package.loaders = {}
    end

    local require -- = require

    if require == nil then
        require = function(module)
            if not package.loaded[module] then
                if not modules[module] then
                    error('Failed loading module "' + module + '"')
                end
                package.loaded[module] = modules[module]() or true
            end
            return package.loaded[module]
        end
    else
        table.insert(package.loaders, function(module) return modules[module] end)
    end

    modules = {
        bootstrapArgs = function() return args end,
        ["addon"]=function (...)
local addonName, addonTable = unpack(require 'bootstrapArgs')

local fl                    = require 'fl'
local IO                    = fl.type.IO
local curry_n               = fl.curry_n
local compose               = fl.compose
local map                   = fl.map
local performUnsafeIO       = fl.performUnsafeIO

local utils                 = require 'utils'
local tableN                = utils.tableN

LoadAddOn('Blizzard_DebugTools')

local dump                     = curry_n(2, function(prefix, v)
    DevTools_Dump({ [prefix] = v }, prefix)
    return v
end)

local newFrame                 = IO.of('FRAME'):map(CreateFrame)

-- String -> Table arguments -> Object -> Any
local invoker                  = curry_n(3, function(method, arguments, object)
    dump('invoker', { method = method, arguments = arguments, object = object })
    return object[method](object, unpack(arguments))
end)

-- (Object o => Any) -> Object o
local fluentSideEffect         = curry_n(2, function(f, o)
    f(o)
    return o
end)

-- Any -> Table
local wrapIntoTable            = tableN(1)

-- String eventName -> Object frame -> Any
local registerEvent            = compose(
--dump,
    invoker('RegisterEvent'),
--dump,
    wrapIntoTable
)

-- Frame -> Any
local registerAddonLoadedEvent = registerEvent('ADDON_LOADED')

-- String scriptType -> (... -> ()) handler -> Object frame -> ()
local bindScriptToFrame        = curry_n(2, function(scriptType, handler, frame) return invoker('SetScript')({scriptType,handler})(frame) end)

-- (... -> ()) handler -> Object frame -> ()
local bindOnEventScriptToFrame = bindScriptToFrame('OnEvent')

local fr                       = CreateFrame('FRAME')

-- (a -> b -> c) f -> (x -> a) g -> (x -> b) h -> x -> c
local B1                       = curry_n(4, function(f, g, h, x) return f(g(x), h(x)) end)


-- (... -> ()) -> Object frame -> ()
local onAddonLoaded            = compose(
    fluentSideEffect(registerAddonLoadedEvent),
    fluentSideEffect(bindOnEventScriptToFrame(function(...)
        dump('onAddonLoaded handler', { ... })
    end))
)

onAddonLoaded(fr)

local eventFrame = performUnsafeIO(newFrame)
local loaded     = false
local loggedIn   = false
local entered    = false
local started    = false

local function startup()
    if started or not loaded or not entered or not loggedIn then
        return
    end

    started = true

    --LoadAddOn('Blizzard_CharacterUI')
    --CharacterFrame:Show()

    print(addonName .. ' ready.')
end

eventFrame:RegisterEvent('PLAYER_LOGIN')
eventFrame:RegisterEvent('ADDON_LOADED')
eventFrame:RegisterEvent 'PLAYER_ENTERING_WORLD'
eventFrame:SetScript('OnEvent', function(self, event, ...)
    if event == 'ADDON_LOADED' and ... == addonName then
        loaded = true
        startup()
    end
    if event == 'PLAYER_LOGIN' then
        loggedIn = true
        startup()
    end
    if event == 'PLAYER_ENTERING_WORLD' then
        entered = true
        startup()
    end
end)
end,
["main"]=function (...)
--require "luarocks.loader"
--local inspect = require 'inspect'
--
--local function dd(...)
--    for i = 1, select('#', ...) do
--        local v = select(i, ...)
--        print(inspect(v))
--    end
--end
--
--local function mkType(name, methodsFactory)
--    local typeMt     = { __index = {} }
--    local type       = setmetatable({ name = name }, typeMt)
--    local methods    = methodsFactory(type)
--    local instanceMt = { __index = methods }
--
--    function typeMt.__index.of(value)
--        local instance = setmetatable({}, instanceMt)
--        instance:init(value)
--        return instance
--    end
--
--    return type
--end
--
--local Maybe    = mkType('Maybe', function(Maybe)
--    return {
--        init = function(self, value)
--            self.value = value
--        end,
--
--        map  = function(self, fn)
--            if self.value ~= nil then
--                return Maybe.of(fn(self.value))
--            else
--                return self
--            end
--        end
--    }
--end)
--
--local instance = Maybe.of(123)
--
--dd(instance:map(function(value) return value + 1 end))
--
--if true then
--    return
--end
--
--local function stringify(v)
--    if v == nil then
--        return 'nil'
--    elseif type(v) == 'number' then
--        return tostring(v)
--    elseif type(v) == 'string' then
--        return '"' .. v .. '"'
--    else
--        return tostring(v)
--    end
--end
--
--local function id(v)
--    return v
--end
--
--local function curry_n(n, f, ...)
--    if select('#', ...) >= n then
--        return f(...)
--    else
--        local args = { ... }
--        return function(...)
--            local mergedArgs = { unpack(args) }
--            local v
--            for i = 1, select('#', ...) do
--                v = select(i, ...)
--                table.insert(mergedArgs, v)
--            end
--            return curry_n(n, f, unpack(mergedArgs))
--        end
--    end
--end
--
--local function compose(...)
--    local fs = { ... }
--    return function(v)
--        for i = table.maxn(fs), 1, -1 do
--            v = fs[i](v)
--        end
--        return v
--    end
--end
--
--local types      = {}
--
--local instanceMt = {
--    __index = {}
--}
--
--function instanceMt:__tostring()
--    return stringify(self.type) .. '(' .. stringify(self.value) .. ')'
--end
--
--function instanceMt.__index:map(fn)
--    return types[self.type.name].map(self, fn)
--end
--
--local def     = (function()
--    local instanceMt = { }
--
--    function instanceMt:new(...)
--        return setmetatable(..., self)
--    end
--
--    function instanceMt:__call(...)
--        return self.code(...)
--    end
--
--    function instanceMt:__tostring(...)
--        return self.signature
--    end
--
--    local builderMt = {
--        __index = { }
--    }
--
--    return function(signature, f)
--        local name, argTypeSignatures, returnType
--        local argTypes                      = {}
--        name, argTypeSignatures, returnType = signature:match('^(.-) :: (.* -> )(.-)$')
--        if name then
--            for match in argTypeSignatures:gmatch('(.-)%s*->%s*') do
--                table.insert(argTypes, match)
--            end
--        else
--            name, returnType = signature:match('^(.-) :: (.-)$')
--            if not name then
--                error('Cannot parse signature: "' .. signature .. '"');
--            end
--        end
--
--        local arity = table.maxn(argTypes)
--
--        local code
--        if arity > 1 then
--            code = curry_n(arity, f)
--        else
--            code = f
--        end
--
--        return instanceMt:new {
--            signature  = signature,
--            name       = name,
--            argTypes   = argTypes,
--            returnType = returnType,
--            arity      = arity,
--            code       = code
--        }
--    end
--end)()
--
--local add     = def(
--    'add :: Number -> Number -> Number',
--    function(a, b) return a + b end
--)
--
--local mul     = def(
--    'mul :: Number -> Number -> Number',
--    function(a, b) return a * b end
--)
--
--local prepend = def(
--    'prepend :: String -> String -> String',
--    function(a, b) return a .. b end
--)
--
--local append  = def(
--    'prepend :: String -> String -> String',
--    function(a, b) return b .. a end
--)
--
--assert(compose(add(1))(1) == 2)
--assert(compose(add(1), mul(2))(3) == 7)
--
--assert(map(add(1), 2) == 3)
--
--local Maybe = (function()
--    local mt = {
--        __index = {}
--    }
--
--    function mt.of(v)
--        return setmetatable({ v = v }, mt)
--    end
--
--    function mt:__tostring()
--        if self:isNothing() then
--            return 'Nothing'
--        else
--            return 'Just(' .. stringify(self.v) .. ')'
--        end
--    end
--
--    function mt.__index:isNothing()
--        return self.v == nil
--    end
--
--    function mt.__index:isJust()
--        return self.v ~= nil
--    end
--
--    function mt.__index:map(fn)
--        if self:isNothing() then
--            return self
--        else
--            return mt.of(fn(self.v))
--        end
--    end
--
--    return mt
--end)()
--
--local maybe = curry_n(3, function(v, f, m)
--    if m:isNothing() then
--        return v
--    else
--        return f(m.v)
--    end
--end)
--
--assert(tostring(Maybe.of(nil)) == 'Nothing')
--assert(tostring(Maybe.of(1)) == 'Just(1)')
--assert(tostring(Maybe.of(1):map(id)) == 'Just(1)')
--assert(tostring(Maybe.of('abc')) == 'Just("abc")')
--assert(tostring(Maybe.of(Maybe.of(1))) == 'Just(Just(1))')
--assert(maybe(1, tostring, Maybe.of(nil)) == 1)
--
--local Left, Right, Either
--
--Left         = (function()
--    local mt = {
--        __index = {}
--    }
--
--    function mt.__index:map(_)
--        return self
--    end
--
--    function mt:__tostring()
--        return 'Left(' .. stringify(self.v) .. ')'
--    end
--
--    return mt;
--end)()
--
--Right        = (function()
--    local mt = {
--        __index = {}
--    }
--
--    function mt.__index:map(f)
--        return Either.of(f(self.v))
--    end
--
--    function mt:__tostring()
--        return 'Right(' .. stringify(self.v) .. ')'
--    end
--
--    return mt;
--end)()
--
--Either       = (function()
--    local mt = {}
--
--    function mt.of(v)
--        return setmetatable({ v = v }, Right)
--    end
--
--    return mt;
--end)()
--
--local left   = function(x)
--    return setmetatable({ v = x }, Left)
--end
--
--local either = curry_n(3, function(f, g, e)
--    local mt = getmetatable(e)
--    if mt == Left then
--        return f(e.v)
--    elseif mt == Right then
--        return g(e.v)
--    else
--        error('Either expects Left or Right as 3rd argument')
--    end
--end)
--
--assert(tostring(left(1)) == 'Left(1)')
--assert(tostring(Either.of(1)) == 'Right(1)')
--assert(either(id, add(1))(Either.of(3)) == 4)
--assert(either(id, add(1))(left('Error')) == 'Error')
--
--local IO = (function()
--    local mt = {
--        __index = {}
--    }
--
--    function mt.new(fn)
--        return setmetatable({ unsafePerformIO = fn }, mt)
--    end
--
--    function mt.of(x)
--        return mt.new(function()
--            return x
--        end)
--    end
--
--    function mt.__index:map(fn)
--        return mt.new(compose(fn, self.unsafePerformIO))
--    end
--
--    function mt.__index:ap(f)
--        return self:chain(function(fn)
--            return f:map(fn)
--        end)
--    end
--
--    function mt.__index:chain(fn)
--        return self:map(fn):join()
--    end
--
--    function mt.__index:join()
--        local this = self
--        return mt.new(function()
--            return this.unsafePerformIO().unsafePerformIO()
--        end)
--    end
--
--    function mt:__tostring()
--        return 'IO(' .. stringify(self.unsafePerformIO) .. ')'
--    end
--
--    return mt
--end)()
--
--assert(IO.of(1).unsafePerformIO() == 1)
--assert(IO.of(1):map(add(1)).unsafePerformIO() == 2)
--
--local Task              = (function()
--    local mt = {
--        __index = {}
--    }
--
--    function mt.new(fork)
--        return setmetatable({ fork = fork }, mt)
--    end
--
--    function mt:__tostring()
--        return 'Task(' .. stringify(self.fork) .. ')'
--    end
--
--    function mt.rejected(x)
--        return mt.new(function(reject, _)
--            return reject(x)
--        end)
--    end
--
--    function mt.of(x)
--        return mt.new(function(_, resolve)
--            return resolve(x)
--        end)
--    end
--
--    function mt.__index:map(fn)
--        local this = self
--        return mt.new(function(reject, resolve)
--            return this.fork(reject, compose(resolve, fn))
--        end)
--    end
--
--    function mt.__index:ap(f)
--        return self:chain(function(fn)
--            return f:map(fn)
--        end)
--    end
--
--    function mt.__index:chain(fn)
--        local this = self
--        return mt.new(function(reject, resolve)
--            return this.fork(reject, function(x)
--                return fn(x).fork(reject, resolve)
--            end)
--        end)
--    end
--
--    function mt.__index:join(f)
--        return self:chain(id)
--    end
--
--    return mt
--end)()
--
--local output            = function(v)
--    return IO.new(function()
--        print(v)
--    end)
--end
--
--local getGlobalValue    = function(name)
--    return IO.new(function()
--        return _G[name]
--    end)
--end
--
--x                       = 'this is x'
--
--local decorate          = compose(
--    prepend('for sure, '),
--    append('!')
--)
--
--local join              = function(f)
--    return f:join()
--end
--
--local chain             = curry_n(2, function(f, fn)
--    return f:chain(fn)
--end)
--
--local log               = curry_n(2, function(m, v)
--    print('[LOG][' .. m .. ']', stringify(v))
--    return v
--end)
--
--local outputGlobalValue = compose(
--    join,
--    map(output),
--    getGlobalValue
--)
--
----print(getGlobalValue('x'):map(decorate).unsafePerformIO())
--
--local outputX           = outputGlobalValue('x')
--outputX.unsafePerformIO()
----outputGlobalValue('x').unsafePerformIO()
--
--local asyncOutput           = function(x)
--    return Task.new(function(reject, resolve)
--        print(x)
--        resolve()
--    end)
--end
--
--local iteratorToTable       = function(it)
--    local v = {}
--    for line in it do
--        table.insert(v, line)
--    end
--    return v
--end
--
--local safeCall2             = curry_n(2, function(f, a)
--    return Task.new(function(reject, resolve)
--        local success, res = pcall(f, a)
--        if success then resolve(res) else reject(res) end
--    end)
--end)
--
--local prop                  = curry_n(2, function(name, v)
--    return v[name]
--end)
--
--local idOf                  = function(x)
--    return function()
--        return x
--    end
--end
--
--local ioLines               = compose(
--    map(prop('lines')),
--    getGlobalValue,
--    idOf('io')
--)
--
--local getLinesFromFile      = def(
--    'getLinesFromFile :: Filename -> Task Error [String]',
--    compose(
--        map(iteratorToTable),
--        safeCall2(io.lines)
--    )
--)
--
----print(t.fork(
----    function(error)
----        print('Error:', error)
----    end,
----    function(result)
----        print('Success:', result)
----    end
----))
--
--local head                  = def(
--    'head :: [a] -> a',
--    function(xs) return xs[1] end
--)
--
--local B1                    = curry_n(4, function(f, g, h, x)
--    return f(g(x), h(x))
--end)
--
--local quote                 = B1(compose, prepend, append)
--
--local unsafePerformIO       = function(io)
--    return io.unsafePerformIO()
--end
--
--local outputFirstLineOfFile = compose(
--    map(unsafePerformIO),
--    map(output),
--    map(quote('"')),
--    map(head),
--    getLinesFromFile
--)
--
--outputFirstLineOfFile('test.txt').fork(
--    function(error)
--        print('Error:', error)
--    end,
--    function(result)
--        print('Success:', result)
--    end
--)
--
--local String                 = defType('String')
--local Filename               = defType('String')
--local _Task                  = defType('String')
--local Error                  = defType('String')
--local Empty                  = defType('()')
--
--local outputFirstLineOfFile2 = def(
--    'outputFirstLineOfFile2 :: Filename -> Task Error Void',
--    compose(
--        map(unsafePerformIO),
--        map(output),
--        map(quote('"')),
--        map(head),
--        getLinesFromFile
--    )
--)
--
--local reportError            = def(
--    'reportError :: Error -> ()',
--    compose(
--        unsafePerformIO,
--        output,
--        prepend('[ERROR] ')
--    )
--)
--
--local reportSuccess          = def(
--    'reportSuccess :: Result -> ()',
--    compose(
--        unsafePerformIO,
--        output,
--        prepend('[SUCCESS] '),
--        stringify
--    )
--)
--
--outputFirstLineOfFile2('test.txt1').fork(
--    reportError,
--    reportSuccess
--)
--
--local NewMaybe = defType('NewMaybe', {
--    map = function(self, fn)
--        if self.value ~= nil then
--            return self.type.of(fn(self.value))
--        else
--            return self
--        end
--    end
--})
--
--dd(NewMaybe)
--
--local m = NewMaybe.of(1)
--dd(m)
--dd(map(add(1), m))
--dd(map(add(1), NewMaybe.of(nil)))
end,
["fl.defType"]=function (...)
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
end,
["fl.compose"]=function (...)
local function compose(...)
    if select('#', ...) == 0 then
        error('At least one argument is required')
    end

    for i = 1, select('#', ...) do
        local f = select(i, ...)
        if type(f) ~= 'function' and not (type(f) == 'table' and getmetatable(f).__call ~= nil) then
            error('Argument #' .. i .. 'must be a function or invokable table')
        end
    end

    local fs = { ... }

    return function(v)
        for i = table.maxn(fs), 1, -1 do
            v = fs[i](v)
        end
        return v
    end
end

return compose
end,
["fl.curry_n"]=function (...)
local function curry_n(n, f, ...)
    if type(n) ~= 'number' or n < 0 then
        error('First argument must be a non-negative integer')
    end

    if type(f) ~= 'function' and not (type(f) == 'table' and getmetatable(f).__call ~= nil) then
        error('Second argument must be a function or invokable table')
    end

    if select('#', ...) >= n then
        return f(...)
    else
        local args = { ... }
        return function(...)
            local mergedArgs = { unpack(args) }
            local v
            for i = 1, select('#', ...) do
                v = select(i, ...)
                table.insert(mergedArgs, v)
            end
            return curry_n(n, f, unpack(mergedArgs))
        end
    end
end

return curry_n
end,
["fl.execute"]=function (...)
local function execute(task, onResolve, onReject)
    task.value(onReject, onResolve)
end

return execute
end,
["fl.map"]=function (...)
local defType = require 'fl.defType'

local function map(fn, v)
    if defType.recognizesInstance(v) then
        return v:map(fn)
    else
        return fn(v)
    end
end

return map
end,
["fl.either"]=function (...)
local Either = require 'fl.type.Either'

local function either(f, g, m)
    if type(m) ~= 'table' or getmetatable(m) ~= Either then
        error('Third argument should be instance of Either')
    end

    if m.right then
        return g(m.value)
    else
        return f(m.value)
    end
end

return either
end,
["fl.combinator"]=function (...)
local curry_n    = require 'fl.curry_n'

local combinator = function(expr)
    local head, body = expr:match('^(%a*)%.([%a()]*)$')

    if not head then
        error('Expression does not match pattern')
    end

    local input = {}
    local code  = 'return function ('

    if head == '' then
        error('Head is empty')
    end

    if body == '' then
        error('Body is empty')
    end

    for n = 1, head:len() do
        local var = head:sub(n, n)

        if input[var] then
            error('Duplicate variable in head: "' .. var .. '"')
        end

        input[var] = true

        if n > 1 then
            code = code .. ', '
        end
        code = code .. var
    end

    code        = code .. ')
    return '

    local depth = 0
    local curr  = { '' }
    for n = 1, body:len() do
        local char = body:sub(n, n)

        if char == '(' then
            depth = depth + 1
            table.insert(curr, '')
            code = code .. '('
        elseif char == ')' then
            if curr[table.maxn(curr)] == '' then
                error('Body has empty brackets')
            end
            table.remove(curr)
            depth = depth - 1
            code  = code .. ')'
        elseif not input[char] then
            error('Unknown variable in body: "' .. char .. '"')
        else
            if curr[table.maxn(curr)] == '' then
                code = code .. char
            else
                code = code .. '(' .. char .. ')'
            end
            curr[table.maxn(curr)] = curr[table.maxn(curr)] .. char
        end
    end

    if depth ~= 0 then
        error('Body has unbalanced brackets')
    end

    code = code .. '
end'

    local compiled, err = loadstring(code, expr)

    if not compiled then
        error('Compilation failed: ' .. err)
    end

    return curry_n(head:len(), compiled())
end

return combinator
end,
["fl.left"]=function (...)
local Either = require 'fl.type.Either'

local function left(v)
    return Either { value = v, right = false }
end

return left
end,
["fl.type.IO"]=function (...)
local defType = require 'fl.defType'

local IO

local function of(value)
    return IO { value = function() return value end }
end

local function map(self, fn)
    return IO { value = function () return fn(self.value()) end }
end

IO = defType()
    :typeMethod('of', of)
    :instanceMethod('map', map)
    :build()

return IO
end,
["fl.type.Either"]=function (...)
local defType = require 'fl.defType'

local Either

local function of(value)
    return Either { value = value, right = true }
end

local function map(self, fn)
    if self.right then
        return Either.of(fn(self.value))
    else
        return self
    end
end

Either = defType()
    :typeMethod('of', of)
    :instanceMethod('map', map)
    :build()

return Either
end,
["fl.type.Task"]=function (...)
local defType = require 'fl.defType'
local compose = require 'fl.compose'

local Task

local function of(value)
    return Task { value = function(_, resolve) return resolve(value) end }
end

local function rejected(value)
    return Task { value = function(reject, _) return reject(value) end }
end

local function map(self, fn)
    return Task { value = function(reject, resolve) return self.value(reject, compose(resolve, fn)) end }
end

Task = defType()
    :typeMethod('of', of)
    :typeMethod('rejected', rejected)
    :instanceMethod('map', map)
    :build()

return Task
end,
["fl.type.Maybe"]=function (...)
local defType = require 'fl.defType'

local Maybe

local function of(value)
    return Maybe { value = value }
end

local function map(self, fn)
    if self.value == nil then
        return self
    else
        return of(fn(self.value))
    end
end

Maybe = defType()
    :typeMethod('of', of)
    :instanceMethod('map', map)
    :build()

return Maybe
end,
["fl.reject"]=function (...)
local Task = require 'fl.type.Task'

local function reject(v)
    return Task.rejected(v)
end

return reject
end,
["fl.performUnsafeIO"]=function (...)
local IO = require 'fl.type.IO'

local function performUnsafeIO(m)
    if type(m) ~= 'table' or getmetatable(m) ~= IO then
        error('Third argument should be instance of IO')
    end

    return m.value()
end

return performUnsafeIO
end,
["fl.maybe"]=function (...)
local Maybe = require 'fl.type.Maybe'

local function maybe(v, fn, m)
    if type(m) ~= 'table' or getmetatable(m) ~= Maybe then
        error('Third argument should be instance of Maybe')
    end

    if m.value ~= nil then
        return fn(m.value)
    else
        return v
    end
end

return maybe
end,
["fl"]=function (...)
return {
    type            = {
        Either = require 'fl.type.Either',
        IO     = require 'fl.type.IO',
        Maybe  = require 'fl.type.Maybe',
        Task   = require 'fl.type.Task',
    },
    combinator      = require 'fl.combinator',
    compose         = require 'fl.compose',
    curry_n         = require 'fl.curry_n',
    defType         = require 'fl.defType',
    either          = require 'fl.either',
    execute         = require 'fl.execute',
    left            = require 'fl.left',
    map             = require 'fl.map',
    maybe           = require 'fl.maybe',
    performUnsafeIO = require 'fl.performUnsafeIO',
    reject          = require 'fl.reject',
}
end,
["utils"]=function (...)
local fl      = require 'fl'
local curry_n = fl.curry_n

-- Number n -> (Any n -> Any n -> ... -> {Any})
local tableN  = function(n)
    return curry_n(n, function(...)
        return { ... }
    end)
end

return {
    tableN = tableN,
}
end,
    }

    return require('addon')
end)()
