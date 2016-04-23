local AnotherComponent = require("Class").create(require("Components.Component"))
function AnotherComponent:constructor(definition, entity)
    self.type = "AnotherComponent"
    self.entity = entity
    definition = definition
    self.nativeType = definition
end

function AnotherComponent:onEvent(Event)
    if Event.type == "ATTRIBUTE_CHANGED" then
    end
end

return AnotherComponent