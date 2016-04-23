local HatComponent = require("Class").create(require("Components.Component"))
function HatComponent:constructor(definition, entity)
    self.type = "HatComponent"
    self.entity = entity
    self.nativeType = definition
end

return HatComponent