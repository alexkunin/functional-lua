local IO = require 'fl.type.IO'

local function performUnsafeIO(m)
    if type(m) ~= 'table' or getmetatable(m) ~= IO then
        error('Third argument should be instance of IO')
    end

    return m.value()
end

return performUnsafeIO
