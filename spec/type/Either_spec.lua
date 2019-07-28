local fl                        = require 'fl'
local Either, map, left, either = fl.type.Either, fl.map, fl.left, fl.either

describe('Either', function()
    describe('of', function()
        it('should create objects with proper metatable', function()
            assert.is_equal(Either, getmetatable(Either.of(1)))
            assert.is_equal(Either, getmetatable(Either.of(nil)))
        end)
    end)

    describe('map', function()
        it('should return instance of Either', function()
            local m1 = Either.of(1)
            local m2 = map(function(v) return v + 2 end, m1)
            assert.is_equal(Either, getmetatable(m2))
        end)

        it('should not modify original instance', function()
            local m1 = Either.of(1)
            local m2 = map(function(v) return v + 2 end, m1)
            assert.is_equal(3, m2.value)
            assert.is_equal(1, m1.value)
        end)
    end)

    describe('left', function()
        it('should return instance of Either', function()
            assert.is_equal(Either, getmetatable(left(1)))
            assert.is_equal(Either, getmetatable(left(nil)))
        end)
    end)

    describe('either', function()
        it('should throw error if not a Either instance is passed', function()
            assert.has_error(function() either(function() end, function() end, nil) end)
            assert.has_error(function() either(function() end, function() end, 1) end)
            assert.has_error(function() either(function() end, function() end, {}) end)
        end)

        it('should call correct function', function()
            assert.is_equal(4, either(function(v) return v + 1 end, function(v) return v + 2 end, left(3)))
            assert.is_equal(5, either(function(v) return v + 1 end, function(v) return v + 2 end, Either.of(3)))
        end)
    end)
end)