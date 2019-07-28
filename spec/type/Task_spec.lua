local fl                    = require 'fl'
local Task, reject, execute = fl.type.Task, fl.reject, fl.execute

describe('Task', function()
    describe('.of', function()
        it('should return instance of Task', function()
            assert.is_equal(Task, getmetatable(Task.of(1)))
        end)

        it('should return successul task', function()
            local r
            execute(Task.of(5), function(v) r = 'resolved' .. v end, function() error('Should never happen') end)
            assert.is_same('resolved5', r)
        end)
    end)

    describe('.rejected', function()
        it('should return instance of Task', function()
            assert.is_equal(Task, getmetatable(Task.rejected(1)))
        end)

        it('should return rejected task', function()
            local r
            execute(Task.rejected(5), function() error('Should never happen') end, function(v) r = 'rejected' .. v end)
            assert.is_same('rejected5', r)
        end)
    end)
end)

describe('reject', function()
    it('should return instance of Task', function()
        assert.is_equal(Task, getmetatable(reject(1)))
    end)

    it('should return rejected task', function()
        local r
        execute(reject(5), function() error('Should never happen') end, function(v) r = 'rejected' .. v end)
        assert.is_same('rejected5', r)
    end)
end)

describe('execute', function()
    it('should execute task', function()
        local r
        execute(Task.of(5), function(v) r = 'resolved' .. v end, function(v) r = 'rejected' .. v end)
        assert.is_same('resolved5', r)
        execute(reject(5), function(v) r = 'resolved' .. v end, function(v) r = 'rejected' .. v end)
        assert.is_same('rejected5', r)
    end)
end)
