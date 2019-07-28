local Either = require 'fl.type.Either'

local function left(v)
    return Either { value = v, right = false }
end

return left
