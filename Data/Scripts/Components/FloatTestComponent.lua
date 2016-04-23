local FloatTestComponent = require("Class").create(require("Components.Component"))
function FloatTestComponent:constructor(definition, entity)
    self.type = "FloatTestComponent"
    self.entity = entity
    self.nativeType = definition
end

return FloatTestComponent