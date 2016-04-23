-- Simple input control system. Registers and removes callbacks

local _Input = {}

local callbacks = {}
local paused = {}
local keyCallbacks = {}
local pointerCallbacks = {}
local lclickCallbacks = {}
local rclickCallbacks = {}
local queue = {}

local CB_TYPE = {}
CB_TYPE.KEYBOARD = "keyboard"
CB_TYPE.POINTER = "pointer"
CB_TYPE.LCLICK = "lclick"
CB_TYPE.RCLICK = "rclick"

local input_init = false

-- Helper Functions

--creats the callback data struct
local function _createCallbackData()
    local cb ={}
    cb.name = ""
    cb.type = ""
    cb.priority = 0
    cb.func = nil
    
    return cb
end

--gets the table containing callbacks for a pass type
local function _getTypeTable(cbType)
    local ctable = nil
    if cbType == CB_TYPE.KEYBOARD then
        ctable = keyCallbacks
    end
    if cbType == CB_TYPE.POINTER then
        ctable = pointerCallbacks
    end
    if cbType == CB_TYPE.LCLICK then
        ctable = lclickCallbacks
    end
    if cbType == CB_TYPE.RCLICK then
        ctable = rclickCallbacks
    end
    
    assert (ctable ~= nil, "No appropriate callback table found")
    
    return ctable
end

--registers a callback from a callback struct
local function _registerCallback(callback)
    assert(callback ~= nil, "nil callback given")

    local ctable = _getTypeTable(callback.type)
    assert(ctable ~= nil, "nil ctable was returned")
    
    local added = false
    
    --look through the table to find a spot for its priority
    for i, v in ipairs(ctable) do
        if callback.priority < v.priority then
            
            table.insert(ctable, i, callback)
            added = true
            break
        end
    end
    
    --none found, add it to the end
    if not added then
        
        table.insert(ctable, callback)
    end

end

--a generalized function to generate a callback data struct to be registered
local function _multiRegister(inputType, name, priority, func)
    assert (inputType ~= nil, "inputType cannot be nil")
    assert (name ~= nil, "name cannot be nil")
    assert (priority ~= nil , "priority cannot be nil")
    assert (func ~= nil, "func cannot be nil")
    
    --checks to see if a callback of that name is already in the system, if not create it
    local cfunc = callbacks[name]
    if cfunc == nil then
        cfunc = _createCallbackData()
    end
    
    --initilize the new data
    cfunc.name = name
    cfunc.type = inputType
    cfunc.priority = priority
    cfunc.func = func
    
    --store the functionback into the list, then register it
    callbacks[name] = cfunc
    --print ("callback registered", name, callbacks[name])
    _registerCallback(cfunc)
end

--handles a callback for any type
local function _handleCallback(data)

    local cbTable = _getTypeTable(data.type) 
    
    for i,v in ipairs(cbTable) do
        queuePackage = {func = v.func, data = data}
        table.insert(queue, queuePackage)
    end
end

local function _handleKeyboard(key, down)
    local data = {}
    data.type = CB_TYPE.KEYBOARD
    data.key = key
    data.is_down = down

    _handleCallback(data)
end

local function _handlePointer( x, y)
    local data = {}
    data.type = CB_TYPE.POINTER
    data.x = x
    data.y = y

    _handleCallback(data)
end

local function _handleLClick(down)
    local data = {}
    data.type = CB_TYPE.LCLICK
    data.is_down = down

    _handleCallback(data)
end

local function _handleRClick(down)
    local data = {}
    data.type = CB_TYPE.RCLICK
    data.is_down = down

    _handleCallback(data)
end



--End Helper functions

-- Public functions

--registers a new keybaord callback
function _Input.registerKeyCallback(name, func, priority)
    if not priority then
        priority = #keyCallbacks + 1 --push it to lowest priority if none given
    end

    _multiRegister(CB_TYPE.KEYBOARD, name, priority, func)
end

function _Input.registerPointerCallback(name, func, priority)
    if not priority then
        priority = #pointerCallbacks + 1 --push it to lowest priority if none given
    end

    _multiRegister(CB_TYPE.POINTER, name, priority, func)
end

function _Input.registerLClickCallback(name, func, priority)
    if not priority then
        priority = #lclickCallbacks + 1 --push it to lowest priority if none given
    end

    _multiRegister(CB_TYPE.LCLICK, name, priority, func)
end

function _Input.registerRClickCallback(name, func, priority)
    if not priority then
        priority = #rclickCallbacks + 1 --push it to lowest priority if none given
    end

    _multiRegister(CB_TYPE.RCLICK, name, priority, func)
end

--Clears a callback from the list by name
function _Input.clearCallback(name)
    assert (name ~= nil)
    local cb = callbacks[name]
    
    if cb == nil then
        MOAILogMgr.log("Callback with name \"" .. name .. "\" not found. Doing nothing\n")
        return
    end
    
    local cbTable = _getTypeTable(cb.type)
    
    for i, v in ipairs(cbTable) do
        if v.name == name then
            table.remove(cbTable, i)
        end
    end
    
    callbacks[name] = nil
end

function _Input.pauseCallback(name)
    if type(name) ~= 'string' then
        error("name of callback must be specified", 2)
    end
    
    local cb = callbacks[name]
    if cb == nil then
        MOAILogMgr.log("Callback with name \"" .. name .. "\" not found. Doing nothing\n")
        return
    end
    
    if paused[name] ~= nil then
        MOAILogMgr.log("Attmpted to pause already paused callback with name \"" .. name .."\"")
        return
    end
    
    local cbTable = _getTypeTable(cb.type)
    
    for i, v in ipairs(cbTable) do
        if v.name == name then
            table.remove(cbTable,i)
        end
    end
    
    paused[name] = cb
end

function _Input.resumeCallback(name)
    if type(name) ~= 'string' then
        error("name of callback must be specified", 2)
    end
    
    local cb = callbacks[name]
    if cb == nil then
        MOAILogMgr.log("Callback with name \"" .. name .. "\" not found. Doing nothing\n")
        return
    end
    
    if paused[name] == nil then
        MOAILogMgr.log("Attempted to resume callback that was not paused with name \"" .. name "\"")
        return
    end
    
    local cbTable = _getTypeTable(cb.type)
    
    local added  = false
    for i,v in ipairs(cbTable) do
        if v.priority < cb.priority then
            table.insert(cbTable, i, cb)
            added = true
            break
        end
    end
    
    if not added then
        table.insert(cbTable, #cbTable + 1, cb)
    end
    
    paused[name] = nil
end

--Initilizes the Input system
function _Input.initialize()
    callbacks = {}
    paused = {}
    keyCallbacks = {}
    pointerCallbacks = {}
    lclickCallbacks = {}
    rclickCallbacks = {}
    queue = {}

    MOAIInputMgr.device.keyboard:setCallback(_handleKeyboard)
    MOAIInputMgr.device.pointer:setCallback(_handlePointer)
    MOAIInputMgr.device.mouseLeft:setCallback(_handleLClick)
    MOAIInputMgr.device.mouseRight:setCallback(_handleRClick)

    input_init = true
end

function _Input.is_initialized()
    return input_init
end

function _Input.shutdown()
    MOAIInputMgr.device.keyboard:setCallback(nil)
    MOAIInputMgr.device.pointer:setCallback(nil)
    MOAIInputMgr.device.mouseLeft:setCallback(nil)
    MOAIInputMgr.device.mouseRight:setCallback(nil)
    
    callbacks = nil
    paused = nil
    keyCallbacks = nil
    pointerCallbacks = nil
    lclickCallbacks = nil
    rclickCallbacks = nil
    queue = nil

    input_init = false
end

function _Input.update(dt)
    local oldQueue = queue
    queue = {}

    for i,v in ipairs(oldQueue) do
        v.func(v.data)
    end
    
    oldQueue = nil
end

return _Input