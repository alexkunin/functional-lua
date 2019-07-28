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
