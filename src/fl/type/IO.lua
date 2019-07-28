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
