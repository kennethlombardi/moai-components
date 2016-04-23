local Class = require("Class")
local ComponentDefinitions = require("Components.ComponentDefinitions")

local ComponentHandler = Class.create({})
function ComponentHandler:constructor(definition, entity)
    -- do setup for anything a component handler will need to know
    -- maybe we register the component with another system
end

function ComponentHandler.create(typeName, definition, entity)
    definition = definition or ComponentDefinitions[typeName]
    return require("Components."..typeName).new(definition, entity)
end

local handlers = {}

for k,v in pairs(require("Components.ComponentDefinitions")) do
   handlers[k] = ComponentHandler
end

return handlers