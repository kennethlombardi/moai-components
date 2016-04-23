local function writeCount(file, count, string)
    for i = 1, count do 
        file:write(string)
    end
end

local function writeWithIndent(file, context, trail)
    writeCount(file, context.tabs * context.tabSize, " ")
    file:write(trail)
end

local function writeTable(file, table)
    file:write("{")
    local positionInTable = 0
    for k,v in pairs(table) do 
        if type(v) == "table" then
            file:write(k.." = ")
            writeTable(file, v)
            file:write(",")
        else 
            -- let the table write as ", x = 0"
            -- or "x = 0" on the first position
            if positionInTable ~= 0 then
                file:write(", "..k.." = "..v)
            else
                file:write(k.." = "..v)
            end
            positionInTable = positionInTable + 1
        end
    end
    file:write("}")
end

local Class = require("Class")

local AttributeProxy = Class.create({})
function AttributeProxy:constructor(typeName, definition, entity, attributeKey)
end

function AttributeProxy:set(value)
    assert(type(value) == type(self.value), self.type.." is meant to hold types of "..type(self.value).." not "..type(value))
    self.value = value
    local message = {type = "ATTRIBUTE_CHANGED", arguments = {attributeKey = self.key, attributeValue = self.value}}
    self.entity:onEvent(message)
    return self
end

local Attribute = Class.create(AttributeProxy)
function Attribute:constructor(typeName, definition, entity, attributeKey)
    -- absorb a default definition from the attribute definition table
    if definition == nil then 
        definition = require("AttributeDefinitions")[typeName]
    end

    -- absorb a default value from definition table
    if definition.value == nil then 
        definition.value = require("AttributeDefinitions")[typeName].value
    end

    assert(definition.value ~= nil, "Attribute proxy cannot store a nil value")
    assert(attributeKey ~= nil, "Attribute key cannot be nil")
    assert(entity ~= nil, "Attribute needs a non nil entity")
    self.type = typeName
    self.key = attributeKey
    self.value = definition.value
    self.entity = entity
end

function Attribute:textSerialize(file, context)
    local leadIn = "[\""..self.key.."\"] = {type = \""..self.type.."\", value = "
    if type(self.value) == "table" then 
        writeWithIndent(file, context, leadIn)
        writeTable(file, self.value)
        file:write("}")
    elseif type(self.value) == "boolean" then 
        local value = "true"
        if self.value == false then value = "false" end
        local string = leadIn..value.."}"
        writeWithIndent(file, context, string)
    else
        local string = leadIn..self.value.."}"
        writeWithIndent(file, context, string) 
    end
end

function Attribute:update(dt)
end

local BoolAttribute = Class.create(Attribute)
function BoolAttribute:getBool()
    return self.value
end

local CameraAttribute = Class.create(Attribute)
function CameraAttribute:getCamera()
    return self.value
end

function CameraAttribute:textSerialize(file, context)
    -- replace self value with a table that contains all of
    -- the underlying type information we want serialized and let
    -- the base serialize handle the table
    local value = {}
    value.position = {}
    value.position.x, value.position.y, value.position.z = self.value:getLoc()

    value.rotation = {}
    value.rotation.x, value.rotation.y, value.rotation.z = self.value:getRot()

    self.value = value
    self.super.textSerialize(self, file, context)
end

function CameraAttribute:constructor(typeName, definition, entity, attributeKey)
    -- call the base constructor to set everything up including self.value as a table
    --  with a definition. 
    self.super.constructor(self, typeName, definition, entity, attributeKey)

    -- Replace self.value with a MOAICamera2D as the actual value
    local value = self.value
    self.value = MOAICamera2D.new()

    -- Use the existing definition of self value to initialize the camera
    if value.position ~= nil then self.value:setLoc(value.position.x, value.position.y, value.position.z) end
    if value.rotation ~= nil then self.value:setRot(value.rotation.x, value.rotation.y, value.rotation.z) end
end

local ViewportAttribute = Class.create(Attribute)
function ViewportAttribute:constructor(typeName, definition, entity, attributeKey)
    self.super.constructor(self, typeName, definition, entity, attributeKey)
    local value = self.value
    self.underlyingValue = MOAIViewport.new()

    assert(value.width ~= nil, "Width of viewport is nil")
    assert(value.height ~= nil, "Height of viewport is nil")

    self.underlyingValue:setSize(value.width, value.height)
    self.underlyingValue:setScale(value.width, value.height)

    self.entity:setViewport(self.underlyingValue)
end

function ViewportAttribute:getViewport()
    return self.value
end

function ViewportAttribute:set(value)
    assert(value.width ~= nil, "ViewportAttribute:set value has nil width")
    assert(value.height ~= nil, "ViewportAttribute:set value has nil height")
    self.underlyingValue:setSize(value.width, value.height)
    self.super.set(self, value)
end

local TableAttribute = Class.create(Attribute)
function TableAttribute:constructor(typeName, definition, entity, attributeKey)
    self.super.constructor(self, typeName, definition, entity, attributeKey)
    assert(type(definition) == "table", "Table attribute stores \"table\" not "..(type(definition.value)))
    self.value = {}
    for k,v in pairs(definition.value) do 
        self.value[k] = v 
    end
end

function TableAttribute:getTable()
    return self.value
end

local NumberAttribute = Class.create(Attribute)
function NumberAttribute:getNumber()
    return self.value
end

local EngineAttributeTypeLookupTable = {
    ["BoolAttribute"] = BoolAttribute,
    ["CameraAttribute"] = CameraAttribute,
    ["ViewportAttribute"] = ViewportAttribute,
    ["TableAttribute"] = TableAttribute,
    ["NumberAttribute"] = NumberAttribute,
}

return EngineAttributeTypeLookupTable