local args = { ... }

return (function()
    local modules

    local package --= _G.package

    if package == nil then
        package = {}
    end

    if package.loaded == nil then
        package.loaded = {}
    end

    if package.loaders == nil then
        package.loaders = {}
    end

    local require -- = require

    if require == nil then
        require = function(module)
            if not package.loaded[module] then
                if not modules[module] then
                    error('Failed loading module "' + module + '"')
                end
                package.loaded[module] = modules[module]() or true
            end
            return package.loaded[module]
        end
    else
        table.insert(package.loaders, function(module) return modules[module] end)
    end

    modules = {
        bootstrapArgs = function() return args end,
        [==[MODULES]==]
    }

    return require('[==[ENTRY_POINT]==]')
end)()
