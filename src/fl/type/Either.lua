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
