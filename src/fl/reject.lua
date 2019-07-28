local Task = require 'fl.type.Task'

local function reject(v)
    return Task.rejected(v)
end

return reject
