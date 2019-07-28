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
