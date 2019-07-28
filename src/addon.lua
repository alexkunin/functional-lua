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
