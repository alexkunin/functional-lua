local defType = require 'fl.defType'
local compose = require 'fl.compose'

local Task

local function of(value)
    return Task { value = function(_, resolve) return resolve(value) end }
end

local function rejected(value)
    return Task { value = function(reject, _) return reject(value) end }
end

local function map(self, fn)
    return Task { value = function(reject, resolve) return self.value(reject, compose(resolve, fn)) end }
end

Task = defType()
    :typeMethod('of', of)
    :typeMethod('rejected', rejected)
    :instanceMethod('map', map)
    :build()

return Task
