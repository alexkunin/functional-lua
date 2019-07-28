local function compose(...)
    if select('#', ...) == 0 then
        error('At least one argument is required')
    end

    for i = 1, select('#', ...) do
        local f = select(i, ...)
        if type(f) ~= 'function' and not (type(f) == 'table' and getmetatable(f).__call ~= nil) then
            error('Argument #' .. i .. 'must be a function or invokable table')
        end
    end

    local fs = { ... }

    return function(v)
        for i = table.maxn(fs), 1, -1 do
            v = fs[i](v)
        end
        return v
    end
end

return compose
