local fl                = require 'fl'
local Maybe, map, maybe = fl.type.Maybe, fl.map, fl.maybe

describe('Maybe', function()
    describe('of', function()
        it('should create objects with proper metatable', function()
            assert.is_equal(Maybe, getmetatable(Maybe.of(1)))
            assert.is_equal(Maybe, getmetatable(Maybe.of(nil)))
        end)
    end)

    describe('map', function()
        it('should return instance of Maybe', function()
            local m1 = Maybe.of(1)
            local m2 = map(function(v) return v + 2 end, m1)
            assert.is_equal(Maybe, getmetatable(m2))
        end)

        it('should apply function to internal value if it is not nil', function()
            local m1 = Maybe.of(1)
            local m2 = map(function(v) return v + 2 end, m1)
            assert.is_equal(3, m2.value)
        end)

        it('should not apply function if internal value is nil', function()
            local m1 = Maybe.of(nil)
            local m2 = map(function(_) error('Should never happen') end, m1)
            assert.is_nil(m2.value)
        end)

        it('should not modify original instance', function()
            local m1 = Maybe.of(1)
            local m2 = map(function(v) return v + 2 end, m1)
            assert.is_equal(3, m2.value)
            assert.is_equal(1, m1.value)
        end)
    end)

    describe('maybe', function()
        it('should throw error if not a Maybe instance is passed', function()
            assert.has_error(function() maybe(123, function() end, nil) end)
            assert.has_error(function() maybe(123, function() end, 1) end)
            assert.has_error(function() maybe(123, function() end, {}) end)
        end)

        it('should return first argument if internal value is nil', function()
            assert.is_equal(123, maybe(123, function() error('Should never happen') end, Maybe.of(nil)))
        end)

        it('should apply function and return its result if internal value is not nil', function()
            assert.is_equal(15, maybe(123, function(v) return v + 5 end, Maybe.of(10)))
        end)
    end)
end)
