local AttributeDefinitions = require("AttributeDefinitions")
local EngineAttributeLookupTable = require("EngineAttributeLookupTable")
local Class = require("Class")
local AttributeHandler = Class.create({})

local AttributeHandler = Class.create(AttributeProxy)
function AttributeHandler:constructor(...)
end

function AttributeHandler.create(typeName, definition, entity, attributeKey)
    local attribute = EngineAttributeLookupTable[typeName].new(typeName, definition, entity, attributeKey)
    return attribute
end

local handlers = {}

for k,v in pairs(AttributeDefinitions) do 
    handlers[k] = AttributeHandler
end

return handlers