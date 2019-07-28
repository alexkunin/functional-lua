local defType = (require 'fl').defType

describe('defType', function()
    it('should recognize only instances of defined types', function()
        local Type = defType():build()
        assert.is_true(defType.recognizesInstance(Type()))
        assert.is_false(defType.recognizesInstance({}))
        assert.is_false(defType.recognizesInstance(1))
        assert.is_false(defType.recognizesInstance(nil))
    end)

    it('should allow create instance', function()
        local Type     = defType():build()
        local instance = Type()
        assert.is_equal(getmetatable(instance), Type)
    end)

    it('should allow create instance from table', function()
        local Type     = defType():build()
        local base     = { field = 1 }
        local instance = Type(base)
        assert.is_equal(instance, base)
        assert.is_equal(getmetatable(instance), Type)
        assert.is_equal(instance.field, 1)
    end)

    it('should allow define type methods', function()
        local Type = defType()
            :typeMethod('method', function(...) return ... end)
            :build()
        local r    = { Type.method(1, 2, 3) }
        assert.is_same({ 1, 2, 3 }, r)
    end)

    it('should allow define bound type methods', function()
        local Type = defType()
            :boundTypeMethod('method', function(...) return ... end)
            :build()
        local r    = { Type.method(1, 2, 3) }
        assert.is_same({ Type, 1, 2, 3 }, r)
    end)

    it('should allow define instance methods', function()
        local Type     = defType()
            :instanceMethod('method', function(...) return ... end)
            :build()
        local instance = Type()
        local r        = { instance:method(1, 2, 3) }
        assert.is_same({ instance, 1, 2, 3 }, r)
    end)
end)
