--[[
        Resource Manager (Singleton)
        ------------------------------------------------------------------------
        This class will be used to access resources. The class will keep a cache
        of previously loaded values that can be quickly loaded from memory. 
        Things in the cache can still be garabage collected if not in use 
        anywhere else.
--]]

require('ResourceManagerConstants')

local RM = {}

--create a cache using a lua weaktable so that it can be garbage collected.
local cache = {}
setmetatable(cache, {__mode = 'v'}) 
local handlers
local holds

-- Initilze the resource manager
function RM.initialize()
    cache = {}
    setmetatable(cache, {__mode = 'v'}) 

    handlers = {}
    holds = {}
    local handle_set = require('ResourceManagerHandlers')
    assert(handle_set)

    for i,v in ipairs(handle_set) do
        RM.registerType(v.typename, v.func)
    end
end


--shuts down the RM.
function RM.shutdown()
    RM.flush()

    holds = nil
    cache = nil
    handlers = nil
end

function RM.update(dt)
    --do nothing for now
end

--registers a new handler for a typename
function RM.registerType(typename, handler)
    if(type(handler) ~= "function") then
        MOAILogMgr.log("ResourceMgr registerType failed: handler was not a function\n")
        return
    end

    typename = string.lower(typename)
    handlers[typename] = handler
end

--hashing function, just unifies to lowercase as a hash for now
function RM.createHash(typename, filename)
    local hash = string.lower(typename .. filename)
    return hash
end



--loads the data from file or cache if avalible. load is done immediatly
function RM.load(typename, filename)
    typename = string.lower(typename)
    filename = string.lower(filename)

    if (type(typename) ~= "string" and not handlers[typename]) then
        MOAILogMgr.log("ResourceMgr load failed: ".. typename .." is not a valid type\n")
        return
    end

    if (type(filename) ~= "string") then
        MOAILogMgr.log("ResourceMgr load failed: filename incorrect type(" .. 
        filename .. ")\n")
        return
    end
    
    local hash = RM.createHash(typename, filename)
    local data = cache[hash]
    
    --load from file if not in cache
    if (data == nil) then
        handler = handlers[typename]
        if not handler then
            MOAILogMgr.log("ResourceMgr load failed: no handler for " .. typename .. '\n')
            return
        end
        
        data = handler(filename)
        if ( not data ) then
        
            MOAILogMgr.log("ResourceMgr load failed:(".. filename ..
            ") load returned nil\n")
            return
        end
        
        cache[hash] = data
    end
    
    return data
end

--loads the resource, but also keeps a reference to not be garbage collected
function RM.loadAndHold(typename, filename)
    local data = RM.load(typename, filename)

    holds[RM.createHash(typename,filename)] = data
    return data
end

--removes the reference so that it can be garbage collected
function RM.releaseHold(typename, filename)
    local hash = RM.createHash(typename, filename)
    holds[hash] = nil
end

--flushes the RM's cache
function RM.flush()
    for k in pairs(cache) do
        cache[k] = nil
    end
    
    holds = {}

    collectgarbage() --maybe this shouldn't be here, side effect?
end

function RM.resourceCount()
    local count = 0
    for _ in pairs(cache) do
        count = count + 1
    end
    
    return count
end

return RM