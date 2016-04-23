local Listener = require("Listener")
local Entity = require("Class").create(Listener)
function Entity:constructor(...)
    Listener.constructor(self, ...)
    self.components = {}
    self.attributes = {}
    return self   
end

function Entity:addAttribute(key, value)
    self.attributes[key] = value
end

function Entity:addComponent(component)
    self.components[component.type] = component
end

function Entity:getAttribute(attributeKey)
    --return AttributeProxy.new(attributeKey, self.attributes[attributeKey], self)
    return self.attributes[attributeKey]
end

function Entity:getAttributeConst(attributeKey)
    --return AttributeProxyConst.new(attributeKey, self.attributes[attributeKey], self)
    return self.attributes[attributeKey]
end

function Entity:getComponent(type)
    -- assume return nil if component doesn't exist
    return self.components[type]
end

function Entity:onEvent(Event)
    for k,v in pairs(self.components) do 
        v:onEvent(Event)
    end
end

function Entity:textSerialize(file, context)
    print(context)
    function writeWithIndent(file, count, trail)
        for i = 1, count do
            file:write("\t")
        end
        file:write(trail)
    end
    writeWithIndent(file, context.tabs, self.type.." =\n")
    writeWithIndent(file, context.tabs, "{\n"); 
    context.tabs = context.tabs + 1
    writeWithIndent(file, context.tabs, "attributes = {\n")
    context.tabs = context.tabs + 1
    for k,v in pairs(self.attributes) do 
        v:textSerialize(file, context)
        file:write(",\n")
        --writeWithIndent(file, context.tabs, "Attribute,\n")
    end
    context.tabs = context.tabs - 1
    writeWithIndent(file, context.tabs, "},\n")
    writeWithIndent(file, context.tabs, "components = {\n")
    context.tabs = context.tabs + 1
    for k,v in pairs(self.components) do 
        v:textSerialize(file, context)
        file:write(",\n")
    end
    context.tabs = context.tabs - 1
    writeWithIndent(file, context.tabs, "},\n")
    context.tabs = context.tabs - 1
    writeWithIndent(file, context.tabs, "}")
end

function Entity:update(dt)
    for attributeKey, attribute in pairs(self.attributes) do 
        attribute:update(dt)
    end
    
    for componentType, component in pairs(self.components) do
        component:update(dt)
    end
end

function Entity.extend(interfaceToExtend)

    function interfaceToExtend:constructor(...)
        Entity.constructor(self, ...)
    end

    function interfaceToExtend:addAttribute(key, value)
        Entity.addAttribute(self, key, value)
    end

    function interfaceToExtend:addComponent(component)
        Entity.addComponent(self, component)
    end

    function interfaceToExtend:getAttribute(attributeKey)
        return Entity.getAttribute(self, attributeKey)
    end

    function interfaceToExtend:getAttributeConst(attributeKey)
        return Entity.getAttributeConst(self, attributeKey)
    end

    function interfaceToExtend:getComponent(type)
        return Entity.getComponent(self, type)
    end

    function interfaceToExtend:onEvent(Event)
        Entity.onEvent(self, Event)
    end

    function interfaceToExtend:textSerialize(file, context)
        Entity.textSerialize(self, file, context)
    end

    function interfaceToExtend:update(dt)
        Entity.update(self, dt)
    end
end

return Entity