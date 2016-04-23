local m = {
    handlers = {}
}

-- entity is a default parameter that will be ignored most of the time
-- entity used for things like creating components that need to know who
-- they are attached to
function m.create(typeName, definition, entity, attributeKey)
    assert(typeName ~= nil, "Factory.create typeName is nil")
    assert(m.handlers[typeName] ~= nil, "Handler for typeName: "..(typeName or "nil").." not definied.")

    -- not all handlers need or use entity e.g AttributeHandlers
    return m.handlers[typeName].create(typeName, definition, entity, attributeKey)
end

function m.createFromFile(type, file)
   local function getDefinition(file)
        local char = ""
        while char ~= "{" do 
            char = file:read(1)
            assert(char ~= nil, "Read to end of file looking for definition of entity")
        end
        local definition = char
        local scope = 1
        while scope ~= 0 do 
            char = file:read(1)
            if char == "}" then scope = scope - 1
            elseif char == "{" then scope = scope + 1
            end
            assert(char ~= nil, "Read to end of file looking for entity definition")
            definition = definition..char
        end
        return definition
    end
    local definition = getDefinition(file)
    return m.create(type, loadstring("return"..definition)())
end

function m.initialize()
    m.handlers = {}
    local handlers = require("EntityHandlers")
    for k,v in pairs(handlers) do
        m.registerHandler(k, v)
    end

    handlers = require("ComponentHandlers")
    for k,v in pairs(handlers) do
        m.registerHandler(k, v)
    end

    handlers = require("AttributeHandlers")
    for k,v in pairs(handlers) do 
        m.registerHandler(k, v)
    end

end

function m.registerHandler(type, handler)
    m.handlers[type] = handler
end

function m.shutdown()
    m.handlers = nil
end

function m.update(dt)
end

return m