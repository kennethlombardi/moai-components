local EntityDefinitions = require("EntityDefinitions")
local Class = require("Class")
local Factory = require("Factory")
local EngineTypeLookupTable = require("EngineEntityTypeLookupTable")

local function addComponentsInDefinition(entity, definition)
    for k,v in pairs(definition or {}) do
        entity:addComponent(Factory.create(k, v, entity))
    end
end

local function addAttributesInDefinition(entity, definition)
    for k,v in pairs(definition or {}) do
        --entity:addAttribute(k,v)
        entity:addAttribute(k, Factory.create(v.type, v, entity, k))
    end
end

local function addMissingComponents(entity)
    local entityDefinition = EntityDefinitions[entity.type].components
    for k,v in pairs(entityDefinition) do
        if entity:getComponent(k) == nil then
            -- not sending defaults for component should give defaults
            -- when component is created. Component didn't exist so defaults
            -- are the best we can do
            entity:addComponent(Factory.create(k, nil, entity))
        end
    end
end

local function addMissingAttributes(entity)
    local attributes = EntityDefinitions[entity.type].attributes
    for k,v in pairs(attributes) do 
        if entity:getAttribute(k) == nil then 
            entity:addAttribute(k, Factory.create(v.type, v, entity, k))
        end
    end
end

local Handler = Class.create({})
function Handler:constructor()
end

function Handler.create(typeName, definition, entity)
    local entity = EngineTypeLookupTable[typeName].new():constructor({})
    addComponentsInDefinition(entity, definition and definition.components)
    addAttributesInDefinition(entity, definition and definition.attributes)
    entity.type = typeName
    addMissingAttributes(entity)
    addMissingComponents(entity)
    return entity
end

local handlers = {}

for k,v in pairs(EntityDefinitions) do 
    handlers[k] = Handler
end

return handlers