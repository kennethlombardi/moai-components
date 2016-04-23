local IncrementerComponent = require("Class").create(require("Components.Component"))
function IncrementerComponent:constructor(definition, entity)
    self.type = "IncrementerComponent"
    self.entity = entity
    definition = definition or {time = 0}
    self.nativeType = require("Components.TableNativeType").new(definition)
end

function IncrementerComponent:update(dt)
    self.super.update(self, dt)
end

return IncrementerComponent