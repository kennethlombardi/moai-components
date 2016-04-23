MOAIProp2D.extend (
    'MDProp2D',
    function (interface, class, superInterface, superClass)    
        -- superInterface here is MOAIProp2D's per instance level methods

        -- superClass is MOAIProp2D's class level static methods
        -- class is MDProp2D class level static methods
        -- interface is MDProp2D per instance methods
        local Entity = require("Props.Entity")
        Entity.extend(interface)

        function interface:constructor(...)
            Entity.constructor(self, ...)
            return self
        end
    end
)

return MDProp2D