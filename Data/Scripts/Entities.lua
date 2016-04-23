--[[
    Something is happening here
]]
local Listener = require("Class").create({})
function Listener:constructor(...)
end

function Listener:onEvent(event)
end

local Entity = require("Class").create(Listener)
function Entity:constructor(...)
    self.components = {}
end

function Entity:addComponent(component)
    self.components[component.type] = component
end

function Entity:update(dt, layer)
    for k,v in pairs(self.components)
        v.update(self, dt, layer)
    end
end