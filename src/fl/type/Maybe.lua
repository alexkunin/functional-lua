local defType = require 'fl.defType'

local Maybe

local function of(value)
    return Maybe { value = value }
end

local function map(self, fn)
    if self.value == nil then
        return self
    else
        return of(fn(self.value))
    end
end

Maybe = defType()
    :typeMethod('of', of)
    :instanceMethod('map', map)
    :build()

return Maybe
