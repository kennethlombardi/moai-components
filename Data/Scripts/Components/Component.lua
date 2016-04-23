local Component = require("Class").create({})
function Component:constructor(definition, entity)
    self.type = "Component"
    self.entity = entity
    self.nativeType = definition
end

function Component:update(dt)
end

function Component:getValue()
    return self.nativeType
end

function Component:onEvent(Event)
end

function Component:textSerialize(file, context)
    function writeTabs(file, count)
        for i = 1, count do
            file:write("\t")
        end
    end

    writeTabs(file, context.tabs)
    file:write("[\""..self.type.."\"]".." = ")

    local typeof = type(self.nativeType)
    if typeof == "table" then
        context.tabs = context.tabs + 1
        file:write("{\n")
        for k,v in pairs(self.nativeType) do 
            writeTabs(file, context.tabs)
            if type(v) == "string" then
                file:write(k.." = ".."\""..v.."\""..",".."\n")
            else
                file:write(k.." = "..v..",".."\n")
            end
        end
        context.tabs = context.tabs - 1
        file:write("}")
    elseif typeof == "number" then
        file:write(self.nativeType)
    elseif typeof == "string" then
        file:write("\""..self.nativeType.."\"")
    end
end

return Component