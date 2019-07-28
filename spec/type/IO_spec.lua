local fl                       = require 'fl'
local IO, map, performUnsafeIO = fl.type.IO, fl.map, fl.performUnsafeIO

describe('IO', function()
    describe('of', function()
        it('should create objects with proper metatable', function()
            assert.is_equal(IO, getmetatable(IO.of(1)))
            assert.is_equal(IO, getmetatable(IO.of(nil)))
        end)
    end)

    describe('map', function()
        it('should return instance of IO', function()
            local m1 = IO.of(1)
            local m2 = map(function(v) return v + 2 end, m1)
            assert.is_equal(IO, getmetatable(m2))
        end)
    end)

    describe('performUnsafeIO', function()
        it('should throw error if not an IO instance is passed', function()
            assert.has_error(function() performUnsafeIO(nil) end)
            assert.has_error(function() performUnsafeIO(1) end)
            assert.has_error(function() performUnsafeIO({}) end)
        end)

        it('should return return internal value', function()
            assert.is_equal(123, performUnsafeIO(IO.of(123)))
        end)
    end)
end)
