local function execute(task, onResolve, onReject)
    task.value(onReject, onResolve)
end

return execute
