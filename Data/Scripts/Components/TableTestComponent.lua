local TableTestComponent = require("Class").create(require("Components.Component"))
function TableTestComponent:constructor(definition, entity)
    self.type = "TableTestComponent"
    self.entity = entity
    self.nativeType = definition
end

return TableTestComponent