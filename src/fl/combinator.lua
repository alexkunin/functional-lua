local curry_n    = require 'fl.curry_n'

local combinator = function(expr)
    local head, body = expr:match('^(%a*)%.([%a()]*)$')

    if not head then
        error('Expression does not match pattern')
    end

    local input = {}
    local code  = 'return function ('

    if head == '' then
        error('Head is empty')
    end

    if body == '' then
        error('Body is empty')
    end

    for n = 1, head:len() do
        local var = head:sub(n, n)

        if input[var] then
            error('Duplicate variable in head: "' .. var .. '"')
        end

        input[var] = true

        if n > 1 then
            code = code .. ', '
        end
        code = code .. var
    end

    code        = code .. ')\n    return '

    local depth = 0
    local curr  = { '' }
    for n = 1, body:len() do
        local char = body:sub(n, n)

        if char == '(' then
            depth = depth + 1
            table.insert(curr, '')
            code = code .. '('
        elseif char == ')' then
            if curr[table.maxn(curr)] == '' then
                error('Body has empty brackets')
            end
            table.remove(curr)
            depth = depth - 1
            code  = code .. ')'
        elseif not input[char] then
            error('Unknown variable in body: "' .. char .. '"')
        else
            if curr[table.maxn(curr)] == '' then
                code = code .. char
            else
                code = code .. '(' .. char .. ')'
            end
            curr[table.maxn(curr)] = curr[table.maxn(curr)] .. char
        end
    end

    if depth ~= 0 then
        error('Body has unbalanced brackets')
    end

    code = code .. '\nend'

    local compiled, err = loadstring(code, expr)

    if not compiled then
        error('Compilation failed: ' .. err)
    end

    return curry_n(head:len(), compiled())
end

return combinator
