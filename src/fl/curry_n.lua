local function curry_n(n, f, ...)
    if type(n) ~= 'number' or n < 0 then
        error('First argument must be a non-negative integer')
    end

    if type(f) ~= 'function' and not (type(f) == 'table' and getmetatable(f).__call ~= nil) then
        error('Second argument must be a function or invokable table')
    end

    if select('#', ...) >= n then
        return f(...)
    else
        local args = { ... }
        return function(...)
            local mergedArgs = { unpack(args) }
            local v
            for i = 1, select('#', ...) do
                v = select(i, ...)
                table.insert(mergedArgs, v)
            end
            return curry_n(n, f, unpack(mergedArgs))
        end
    end
end

return curry_n
