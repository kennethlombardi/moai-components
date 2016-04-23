local LayerTestComponent = require("Class").create(require("Components.Component"))
function LayerTestComponent:constructor(definition, entity)
    self.type = "LayerTestComponent"
    self.entity = entity
    if definition == "DEFAULT" then definition = {time = 0} end
    definition = definition or {time = 0}
    self.nativeType = definition
end

function LayerTestComponent:update(dt)
    self.super.update(self, dt)
    local time = self:getValue().time
    time = time + dt
    self:getValue().time = time
    if time > 1 then 
        self.entity:getAttribute("visible"):set(false)
    end
end

function LayerTestComponent:onEvent(Event)
    if Event.type == "ATTRIBUTE_CHANGED" then
    end
end

return LayerTestComponent