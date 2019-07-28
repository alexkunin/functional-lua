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
