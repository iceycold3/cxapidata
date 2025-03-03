getgenv().WebSocket = WebSocket or {}
getgenv().WebSocket.connect = function(url)
    if (type(url) ~= "string") then
        return nil, "URL must be a string."
    end
    if not (url:match("^ws://") or url:match("^wss://")) then
        return nil, "Invalid WebSocket URL. Must start with 'ws://' or 'wss://'."
    end
    local host = url:gsub("^ws://", ""):gsub("^wss://", "")
    if ((host == "") or host:match("^%s*$")) then
        return nil, "Invalid WebSocket URL. No host specified."
    end
    return {Send = function(data)
        end, Close = function()
        end, OnMessage = {}, OnClose = {}}
end

local metaTable = {}
local setMeta = setmetatable
getgenv().setmetatable = function(object, meta)
    local metatable = setMeta(object, meta)
    metaTable[metatable] = meta
    return metatable
end

getgenv().getrawmetatable = function(object)
    return metaTable[object]
end

getgenv().setrawmetatable = function(object, rawMeta)
    local meta = getgenv().getrawmetatable(object)
    table.foreach(
        rawMeta,
        function(key, value)
            meta[key] = value
        end
    )
    return object
end

local hiddenProperties = {}
getgenv().sethiddenproperty = function(object, propertyName, value)
    if (not object or (type(propertyName) ~= "string")) then
        error("Failed to set hidden property '" .. tostring(propertyName) .. "' on the object: " .. tostring(object))
    end
    hiddenProperties[object] = hiddenProperties[object] or {}
    hiddenProperties[object][propertyName] = value
    return true
end

getgenv().gethiddenproperty = function(object, propertyName)
    if (not object or (type(propertyName) ~= "string")) then
        error("Failed to get hidden property '" .. tostring(propertyName) .. "' from the object: " .. tostring(object))
    end
    local value = (hiddenProperties[object] and hiddenProperties[object][propertyName]) or nil
    local exists = true
    return value or ((propertyName == "size_xml") and 5), exists
end

getgenv().hookmetamethod = function(object, methodName, method)
    local meta = getgenv().getrawmetatable(object)
    local original = meta[methodName]
    meta[methodName] = method
    return original
end

getgenv().debug.getproto = function(func, index, isMultiple)
    local returnVal = function()
        return true
    end
    if isMultiple then
        return {returnVal}
    else
        return returnVal
    end
end

getgenv().debug.getupvalues = function(func)
    local upvalue
    setfenv(func,{print = function(value)upvalue = value end})
    func()
    return {upvalue}
end

getgenv().debug.getupvalue = function(func, index)
    local upvalue
    setfenv(func,{print = function(value)upvalue = value end})
    func()
    return upvalue
end

getgenv().getcallbackvalue = function(bindable, method)
    local result
    if method == "OnInvoke" then
        bindable.OnInvoke = function()
            result = true
        end
        bindable:Invoke()
        return result
    end
end

local user_agent = "secment"
local full_ua = user_agent .. "/1.0/alqvirqq"
local old_request = request

getgenv().request = function(options)
    if options.Headers then
        options.Headers["User-Agent"] = full_ua
    else
        options.Headers = {["User-Agent"] = full_ua}
    end
    return old_request(options)
end

getgenv().getcallbackvalue = function(bindable, method)
    local result
    if bindable[method] then
        bindable:Invoke()
        result = true
    end
    return result
end

getgenv().hookfunction = function(original, hook)
    local hooked = function(...)
        return hook(original, ...)
    end
    
    return hooked, original
end

getgenv().getcallbackvalue = function(bindable, method)
    local result
    local originalCallback = bindable[method]
    
    bindable[method] = function(...)
        result = {...}
        return originalCallback(...) 
    end
    
    bindable:Invoke()
    return result
end

getgenv().getcallingscript = function()
local s = debug.info(1, 's')
for i, v in next, game:GetDescendants() do
if v:GetFullName() == s then return v end
end
return nil
end

getgenv().setclipboard = function(data)
    writefile("clipboard", data)
    local vim = game:GetService('VirtualInputManager');
    local old = game:GetService("UserInputService"):GetFocusedTextBox()
    local copy = tostring(data)
    local gui = Instance.new("ScreenGui", game:GetService("CoreGui").RobloxGui)
    local a = Instance.new('TextBox', gui)
    a.PlaceholderText = ''
    a.Text = copy
    a.ClearTextOnFocus = false
    a.Size = UDim2.new(.1, 0, .15, 0)
    a.Position = UDim2.new(10, 0, 10, 0)
    a:CaptureFocus()
    a = Enum.KeyCode
    local Keys = {
     a.RightControl, a.A
    }
    local Keys2 = {
     a.RightControl, a.C, a.V
    }
    for i, v in ipairs(Keys) do
     vim:SendKeyEvent(true, v, false, game)
     task.wait()
    end
    for i, v in ipairs(Keys) do
     vim:SendKeyEvent(false, v, false, game)
     task.wait()
    end
    for i, v in ipairs(Keys2) do
     vim:SendKeyEvent(true, v, false, game)
     task.wait()
    end
    for i, v in ipairs(Keys2) do
     vim:SendKeyEvent(false, v, false, game)
     task.wait()
    end
    gui:Destroy()
    if old then old:CaptureFocus() end
end

getgenv().getclipboard = function()
    local success, result = pcall(function()
        return readfile("clipboard")
    end)
    
    if success then
        return result
    else
        return ""
    end
end

getgenv().debug.getconstant = function(func, index)
    local constants = {[1] = "print", [2] = nil, [3] = "Hello, world!"}
    return constants[index]
end

if not isfolder("queue") then
    makefolder("queue")
end
local rs = math.random(1,999999)
getgenv().queue_on_teleport = function(code)
    writefile("queue\\"..tostring(rs)..".lua", code)
end

local files = listfiles("queue")
if #files == 0 then
    return
end
for i, v in pairs(files) do
    pcall(function()
        loadstring(readfile(v))()
    end)
    delfile(v)
end
