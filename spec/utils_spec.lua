local utils  = require 'utils'
local tableN = utils.tableN

describe('tableN', function()
    it('should return a function', function()
        assert.is_function(tableN(3))
    end)

    it('should by curried', function()
        local f = tableN(3)
        assert.is_same({ 1, 2, 3 }, f(1, 2, 3))
        assert.is_same({ 1, 2, 3 }, f(1, 2)(3))
        assert.is_same({ 1, 2, 3 }, f(1)(2, 3))
        assert.is_same({ 1, 2, 3 }, f(1)(2)(3))
    end)
end)
