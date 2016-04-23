local CameraTestListenerComponent = require("Class").create(require("Components.Component"))
function CameraTestListenerComponent:constructor(definition, entity)
    self.type = "CameraTestListenerComponent"
    self.entity = entity
    self.nativeType = definition
end

function CameraTestListenerComponent:onEvent(event)
    if event.type == "ATTRIBUTE_CHANGED" then
        if event.arguments.attributeKey == "CameraAttribute" then 
            local lifeAttribute = self.entity:getAttribute("life")
            lifeAttribute:set(lifeAttribute:getNumber() - 1)
        end
    end
end

return CameraTestListenerComponent