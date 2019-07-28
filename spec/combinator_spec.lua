local combinator = require 'fl.combinator'

describe('combinator', function()
    it('should compile single input expressions', function()
        assert.is_same(5, combinator('a.a')(5))
    end)

    it('should compile multiple input expressions', function()
        assert.is_same(10, combinator('ab.ab')(function(v) return v * 2 end)(5))
        assert.is_same(1, combinator('ab.a')(1)(2))
        assert.is_same(2, combinator('ab.b')(1)(2))
    end)

    it('should obey brackets', function()
        local add2 = function(v) return v + 2 end
        assert.is_same(13, combinator('fx.f(f(f(fx)))')(add2)(5))
    end)

    it('should complain about empty head or body', function()
        assert.has_error(function() combinator('.a') end)
        assert.has_error(function() combinator('a.') end)
        assert.has_error(function() combinator('.') end)
    end)

    it('should complain about duplicate variables in head', function()
        assert.has_error(function() combinator('aa.a') end)
    end)

    it('should complain about unknown variables in body', function()
        assert.has_error(function() combinator('a.b') end)
    end)

    it('should complain about unbalanced brackets', function()
        assert.has_error(function() combinator('a.(a') end)
        assert.has_error(function() combinator('a.a)') end)
        assert.has_error(function() combinator('a.(a))') end)
        assert.has_error(function() combinator('a.)(a)') end)
    end)

    it('should complain about empty brackets', function()
        assert.has_error(function() combinator('a.()') end)
        assert.has_error(function() combinator('a.a()') end)
    end)
end)
