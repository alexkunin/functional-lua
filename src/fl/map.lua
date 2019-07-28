local defType = require 'fl.defType'

local function map(fn, v)
    if defType.recognizesInstance(v) then
        return v:map(fn)
    else
        return fn(v)
    end
end

return map
