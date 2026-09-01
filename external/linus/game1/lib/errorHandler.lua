SHOW_ERRORS = true
MAX_ERRORS = 5

GameActive = true
Errors = {}
function AddError(err)
    table.insert(Errors, err)
    if #Errors > MAX_ERRORS then
        GameActive = false
    end
end
function SafeCall(func)
    local success, err = pcall(function()
        func()
    end)
    if not success then AddError(err) end
end