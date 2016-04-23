local LifeComponent = require("Class").create(require("Components.Component"))
function LifeComponent:constructor(definition, entity)
    self.super.constructor(self, definition, entity)
    self.type = "LifeComponent"
    self.nativeType = definition
end

function LifeComponent:onEvent(Event)
    if Event.type == "TEST_DAMAGE" then 
        print("TEST_DAMAGE")
        local lifeAttribute = self.entity:getAttribute("life")
        lifeAttribute:set(lifeAttribute:getNumber() - Event.arguments.amount)
    end
end

function LifeComponent:update(dt)
    self.super.update(self, dt)
end

return LifeComponent