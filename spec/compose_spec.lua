local compose = (require 'fl').compose

describe('compose', function()
    describe('argument checks', function()
        it('should not accept anything but callables', function()
            assert.has_error(function() compose(nil) end)
            assert.has_error(function() compose(1) end)
            assert.has_error(function() compose(table) end)
        end)

        it('should require at least one argument', function()
            assert.has_error(function() compose() end)
        end)
    end)

    describe('normal operation', function()
        it('should call passed arguments in reverse order', function()
            local log = {}
            local f   = function(v) return function() table.insert(log, v) end end
            compose(f(1), f(2), f(3))()
            assert.is_same({ 3, 2, 1 }, log)
        end)

        it('should pass outputs as inputs and return last output', function()
            local log = {}
            local f   = function(q) return function(v)
                table.insert(log, v)
                return v * q
            end end
            assert.is_same(120, compose(f(2), f(3), f(4))(5))
            assert.is_same({ 5, 20, 60 }, log)
        end)

        it('should work with empty input', function()
            assert.is_same(1, compose(function() return 1 end)())
        end)
    end)
end)
