MOAILayer.extend (
    'MDLayer2D',
    function (interface, class, superInterface, superClass)   

        local Entity = require("Props.Entity")
        Entity.extend(interface)

        function interface:constructor(...)
            -- this is explicitly calling the non
            -- MOAI constructor to allow the remaining inheritance
            -- chain to continue on using interface:constructor overloading
            Entity.constructor(self, ...)
            self:setPartition(MOAIPartition.new())
            return self
        end
    end
)

return MDProp2D