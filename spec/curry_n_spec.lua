local curry_n = (require 'fl').curry_n

describe('curry_n', function()
    local _add = function(a, b) return a + b end

    describe('argument checks', function()
        it('should accept any callable', function()
            assert.is_same(5, curry_n(1, function(a) return a end)(5))
            assert.is_same(5, curry_n(1, setmetatable({}, { __call = function(self, a) return a end }))(5))
        end)

        it('should fail with invalid n', function()
            assert.has_error(function() curry_n(-1, function() end) end)
            assert.has_error(function() curry_n(nil, function() end) end)
            assert.has_error(function() curry_n({}, function() end) end)
        end)

        it('should fail with non-callable', function()
            assert.has_error(function() curry_n(1, nil) end)
            assert.has_error(function() curry_n(1, 1) end)
            assert.has_error(function() curry_n(1, {}) end)
        end)
    end)

    describe('normal operation', function()
        it('should allow immediate call with all arguments at once', function()
            assert.is_same(3, curry_n(2, _add)(1, 2))
        end)

        it('should call function when all arguments supplied', function()
            assert.is_same(3, curry_n(2, _add)(1)(2))
            assert.is_same(3, curry_n(2, _add)(1)()(2))
        end)
    end)

    describe('edge cases', function()
        it('should ignore empty argument calls', function()
            assert.is_same(3, curry_n(2, _add)(1)()(2))
        end)

        it('should immediately call function if n = 0', function()
            assert.is_same(1, curry_n(0, function() return 1 end))
        end)

        it('should immediately call function if all arguments supplied', function()
            assert.is_same(5, curry_n(1, function(a) return a end, 5))
        end)
    end)
end)
